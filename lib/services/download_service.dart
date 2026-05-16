import 'package:flutter/foundation.dart';
import 'dart:io' as io;
import 'dart:convert';
import 'dart:ui';
import 'dart:async';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_item.dart';

class DownloadedItem {
  final String id; // This will now be the FlutterDownloader taskId
  final String title;
  final String localPath;
  final String? logoUrl;
  final String? seriesName;
  final int? season;
  final int? episode;
  final DateTime downloadedAt;
  final int fileSize;
  int status; // 0: pending, 1: running, 2: completed, 3: failed, 4: canceled

  DownloadedItem({
    required this.id,
    required this.title,
    required this.localPath,
    this.logoUrl,
    this.seriesName,
    this.season,
    this.episode,
    required this.downloadedAt,
    required this.fileSize,
    this.status = 2, // Default to completed for legacy compat
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'localPath': localPath,
    'logoUrl': logoUrl,
    'seriesName': seriesName,
    'season': season,
    'episode': episode,
    'downloadedAt': downloadedAt.toIso8601String(),
    'fileSize': fileSize,
    'status': status,
  };

  factory DownloadedItem.fromJson(Map<String, dynamic> json) => DownloadedItem(
    id: json['id'],
    title: json['title'],
    localPath: json['localPath'],
    logoUrl: json['logoUrl'],
    seriesName: json['seriesName'],
    season: json['season'],
    episode: json['episode'],
    downloadedAt: DateTime.parse(json['downloadedAt']),
    fileSize: json['fileSize'] ?? 0,
    status: json['status'] ?? 2,
  );

  bool get isSeries => seriesName != null && seriesName!.isNotEmpty;

  String get displayTitle {
    if (isSeries && season != null && episode != null) {
      return '$seriesName - T${season}E$episode';
    }
    return title;
  }
}

class DownloadTask {
  final String id;
  final MediaItem item;
  double progress;
  DownloadTaskStatus status;

  final String? localPath;

  DownloadTask({
    required this.id,
    required this.item,
    this.progress = 0.0,
    this.status = DownloadTaskStatus.undefined,
    this.localPath,
  });
}

@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  debugPrint('Background Isolate Callback: $id, $status, $progress');
  final SendPort? send = IsolateNameServer.lookupPortByName(
    'downloader_send_port',
  );
  send?.send([id, status, progress]);
}

class DownloadService extends ChangeNotifier {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Dio _dio = Dio();
  final Map<String, DownloadTask> _activeTasks = {};
  final ReceivePort _port = ReceivePort();
  static const String _portName = 'downloader_send_port';
  StreamSubscription? _portSubscription;

  // Callbacks are removed in favor of notifyListeners()

  Future<void> initialize() async {
    print('DownloadService: Initializing...');

    // Register the port for the background isolate
    IsolateNameServer.removePortNameMapping(_portName);
    IsolateNameServer.registerPortWithName(_port.sendPort, _portName);

    // Listen to updates from the background isolate
    _portSubscription = _port.listen((dynamic data) async {
      String id = data[0];
      int statusIdx = data[1];
      int progress = data[2];

      DownloadTaskStatus status = _mapStatus(statusIdx);

      print(
        'Download Update (Main Isolate): id=$id, status=${status.toString()}, progress=$progress',
      );

      // Update task in map
      if (_activeTasks.containsKey(id)) {
        final task = _activeTasks[id]!;
        task.progress = progress / 100.0;
        task.status = status;

        // Notify listeners for UI updates
        notifyListeners();

        if (status == DownloadTaskStatus.complete) {
          print('DownloadService: Task $id completed successfully.');
          await _handleDownloadCompletion(task, true);
        } else if (status == DownloadTaskStatus.failed) {
          print('DownloadService: Task $id failed.');
          await _handleDownloadCompletion(
            task,
            false,
            error: 'Falha no download',
          );
        } else if (status == DownloadTaskStatus.canceled) {
          print('DownloadService: Task $id canceled.');
          _activeTasks.remove(id);
          notifyListeners();
        }
      } else {
        // If we get an update for a task not in _activeTasks, try to sync it
        print(
          'DownloadService: Received update for unknown task $id. Syncing...',
        );
        if (status == DownloadTaskStatus.running ||
            status == DownloadTaskStatus.enqueued) {
          await syncActiveTasks();
        }
      }
    });

    // Register static callback
    if (!kIsWeb) {
      await FlutterDownloader.registerCallback(downloadCallback);
      // Sync tasks after initialization
      await syncActiveTasks();
    }
  }

  DownloadTaskStatus _mapStatus(int statusIdx) {
    switch (statusIdx) {
      case 0:
        return DownloadTaskStatus.undefined;
      case 1:
        return DownloadTaskStatus.enqueued;
      case 2:
        return DownloadTaskStatus.running;
      case 3:
        return DownloadTaskStatus.complete;
      case 4:
        return DownloadTaskStatus.failed;
      case 5:
        return DownloadTaskStatus.canceled;
      case 6:
        return DownloadTaskStatus.paused;
      default:
        return DownloadTaskStatus.undefined;
    }
  }

  Future<void> syncActiveTasks() async {
    if (kIsWeb) return;
    try {
      final tasks = await FlutterDownloader.loadTasks();
      if (tasks == null) return;

      final records = await getDownloadedItems();

      for (var task in tasks) {
        if (task.status == DownloadTaskStatus.running ||
            task.status == DownloadTaskStatus.enqueued ||
            task.status == DownloadTaskStatus.paused) {
          // Try to find the matching record to get the MediaItem and localPath
          final record = records.firstWhere(
            (r) => r.id == task.taskId,
            orElse: () => DownloadedItem(
              id: task.taskId,
              title: task.filename ?? 'Desconhecido',
              localPath: '',
              downloadedAt: DateTime.now(),
              fileSize: 0,
            ),
          );

          if (record.localPath.isNotEmpty) {
            _activeTasks[task.taskId] = DownloadTask(
              id: task.taskId,
              item: MediaItem(
                title: record.title,
                url: task.url,
                logoUrl: record.logoUrl,
                isSeries: record.isSeries,
                season: record.season,
                episode: record.episode,
              ),
              progress: task.progress / 100.0,
              status: task.status,
              localPath: record.localPath,
            );
          }
        }
      }
    } catch (e) {
      print('Error syncing tasks: $e');
    }
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping(_portName);
    _portSubscription?.cancel();
    super.dispose();
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;
    if (io.Platform.isAndroid) {
      final status = await Permission.storage.request();
      await Permission.notification.request();
      if (status.isGranted) return true;

      if (await Permission.photos.isGranted ||
          await Permission.videos.isGranted) {
        return true;
      }

      return true;
    }
    return true;
  }

  Future<io.Directory?> _getDownloadsDirectory() async {
    if (kIsWeb) return null;
    // On modern Android (11+), getExternalStorageDirectory can be restrictive or behave unexpectedly with Scoped Storage
    // We'll prioritize getApplicationDocumentsDirectory for maximum reliability as it's private to the app but persistent.

    final io.Directory appDir;
    if (io.Platform.isAndroid) {
      // Use getExternalStorageDirectory which maps to Context.getExternalFilesDir(null)
      // This is app-private external storage, safe on Android 11+
      final extDir = await getExternalStorageDirectory() as io.Directory?;
      appDir =
          extDir ?? await getApplicationDocumentsDirectory() as io.Directory;
    } else {
      appDir = await getApplicationDocumentsDirectory() as io.Directory;
    }

    final downloadsDir = io.Directory('${appDir.path}/StartFlix_Downloads');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    print('DownloadService: Using directory: ${downloadsDir.path}');
    return downloadsDir;
  }

  String _sanitizeFilename(String title) {
    // Basic normalization: replace spaces with _
    String safe = title.replaceAll(RegExp(r'\s+'), '_');

    // Remove all characters except alphanumeric, underscore, dash, and dot
    // This effectively strips accents and special chars which might cause FS issues
    safe = safe.replaceAll(RegExp(r'[^a-zA-Z0-9\-_.]'), '');

    if (safe.isEmpty) {
      safe = 'download_${DateTime.now().millisecondsSinceEpoch}';
    }
    return safe;
  }

  Future<String?> startDownload(MediaItem item) async {
    if (kIsWeb) return 'Not supported on web';
    final dir = await _getDownloadsDirectory();
    if (dir == null) return null;

    // 1. IMPROVED URL HANDLING
    String downloadUrl = item.url.trim();
    String ext = '.mp4'; // Default extension

    // Check if it's an M3U8 (HLS)
    if (downloadUrl.toLowerCase().contains('.m3u8')) {
      print(
        'DownloadService: M3U8 detected for ${item.title}. Attempting to convert to .ts for direct download.',
      );
      // Try to convert .m3u8 to .ts which many IPTV panels support for direct download
      downloadUrl = downloadUrl.replaceAll('.m3u8', '.ts');
      ext = '.ts';
    } else if (downloadUrl.toLowerCase().contains('.ts')) {
      ext = '.ts';
    } else if (downloadUrl.toLowerCase().contains('.mkv')) {
      ext = '.mkv';
    } else if (downloadUrl.toLowerCase().contains('.avi')) {
      ext = '.avi';
    }

    // 2. FILENAME CONSTRUCTION
    String filename;
    if (item.isSeries && item.season != null && item.episode != null) {
      filename =
          '${_sanitizeFilename(item.title)}_T${item.season}E${item.episode}$ext';
    } else {
      filename = '${_sanitizeFilename(item.title)}$ext';
    }

    final savePath = '${dir.path}/$filename';
    if (io.File(savePath).existsSync()) {
      print('File already exists: $savePath');
      return 'exists';
    }

    print('DownloadService: Starting download for ${item.title}');
    print('DownloadService: Final URL = $downloadUrl');

    // 3. START DOWNLOAD (FlutterDownloader)
    final taskId = await FlutterDownloader.enqueue(
      url: downloadUrl,
      savedDir: dir.path,
      fileName: filename,
      showNotification: true,
      openFileFromNotification: true,
      saveInPublicStorage: false,
      allowCellular: true,
      timeout: 60000, // 1 minute timeout
    );

    if (taskId != null) {
      final task = DownloadTask(
        id: taskId,
        item: item,
        status: DownloadTaskStatus.enqueued,
        localPath: savePath,
      );
      _activeTasks[taskId] = task;

      print('Started download: $taskId to $savePath');

      await _saveDownloadRecord(
        DownloadedItem(
          id: taskId,
          title: item.title,
          localPath: savePath,
          logoUrl: item.logoUrl,
          seriesName: item.isSeries ? item.title : null,
          season: item.season,
          episode: item.episode,
          downloadedAt: DateTime.now(),
          fileSize: 0,
          status: 1, // Running
        ),
      );
    }

    return taskId;
  }

  void cancelDownload(String taskId) {
    if (!kIsWeb) FlutterDownloader.cancel(taskId: taskId);
    _activeTasks.remove(taskId);
    _updateRecordStatus(taskId, 4);
  }

  Future<void> _handleDownloadCompletion(
    DownloadTask task,
    bool success, {
    String? error,
  }) async {
    if (success) {
      int size = 0;
      try {
        if (task.localPath != null && !kIsWeb) {
          final file = io.File(task.localPath!);
          if (await file.exists()) {
            size = await file.length();
          }
        }
      } catch (e) {
        print('Error getting file size for ${task.id}: $e');
      }

      await _updateRecordStatus(task.id, 2, fileSize: size); // 2 for completed
      notifyListeners();
    } else {
      await _updateRecordStatus(task.id, 3); // 3 for failed
      notifyListeners();
    }
    _activeTasks.remove(task.id);
    notifyListeners();
  }

  Future<void> _saveDownloadRecord(DownloadedItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> downloads = prefs.getStringList('downloads_v2') ?? [];

      downloads.removeWhere((str) {
        try {
          final existing = DownloadedItem.fromJson(jsonDecode(str));
          return existing.id == item.id || existing.localPath == item.localPath;
        } catch (_) {
          return false;
        }
      });

      downloads.add(jsonEncode(item.toJson()));
      await prefs.setStringList('downloads_v2', downloads);
    } catch (e) {
      print('Error saving record: $e');
    }
  }

  Future<void> _updateRecordStatus(
    String taskId,
    int newStatus, {
    int? fileSize,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> downloads = prefs.getStringList('downloads_v2') ?? [];

    List<String> newDownloads = [];
    for (var str in downloads) {
      try {
        var json = jsonDecode(str);
        if (json['id'] == taskId) {
          json['status'] = newStatus;
          if (fileSize != null) json['fileSize'] = fileSize;
          newDownloads.add(jsonEncode(json));
        } else {
          newDownloads.add(str);
        }
      } catch (_) {}
    }
    await prefs.setStringList('downloads_v2', newDownloads);
  }

  Future<List<DownloadedItem>> getDownloadedItems() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> downloads = prefs.getStringList('downloads_v2') ?? [];
    List<DownloadedItem> items = [];

    for (var str in downloads) {
      try {
        final item = DownloadedItem.fromJson(jsonDecode(str));
        // Only add completed items if the file exists
        // For running items, add them regardless of file existence (it's being downloaded)
        if (item.status == 2) {
          // Completed
          if (!kIsWeb && await io.File(item.localPath).exists()) {
            items.add(item);
          } else {
            // If record says complete but file is gone, remove record
            // This cleanup might be better in a dedicated cleanup function
            // print('Warning: Completed download record found but file missing: ${item.localPath}');
          }
        } else if (item.status == 1) {
          // Running/Enqueued
          items.add(item);
        }
      } catch (_) {}
    }
    items.sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
    return items;
  }

  Future<void> deleteDownload(DownloadedItem item) async {
    try {
      if (!kIsWeb) {
        final file = io.File(item.localPath);
        if (await file.exists()) await file.delete();
      }
    } catch (_) {}

    try {
      if (!kIsWeb) {
        await FlutterDownloader.remove(
          taskId: item.id,
          shouldDeleteContent: false, // Content is already deleted above
        );
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    List<String> downloads = prefs.getStringList('downloads_v2') ?? [];
    downloads.removeWhere((str) {
      try {
        final i = DownloadedItem.fromJson(jsonDecode(str));
        return i.id == item.id;
      } catch (_) {
        return false;
      }
    });
    await prefs.setStringList('downloads_v2', downloads);
  }

  bool isDownloading(String title) {
    return _activeTasks.values.any(
      (t) => t.item.title == title && t.status == DownloadTaskStatus.running,
    );
  }

  double getProgress(String title) {
    final task = _activeTasks.values.firstWhere(
      (t) => t.item.title == title,
      orElse: () => DownloadTask(
        id: '',
        item: MediaItem(title: '', url: ''),
        progress: 0,
      ),
    );
    return task.id.isNotEmpty ? task.progress : 0;
  }

  // Public methods restored for DownloadsScreen
  Map<String, DownloadTask> get activeTasks => _activeTasks;

  Future<int> getTotalDownloadSize() async {
    final items = await getDownloadedItems();
    return items.fold<int>(0, (sum, item) => sum + item.fileSize);
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
