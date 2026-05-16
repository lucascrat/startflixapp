import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/download_service.dart';
import '../core/constants.dart';
import 'video_player_screen.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  final DownloadService _downloadService = DownloadService();
  List<DownloadedItem> _downloads = [];
  bool _isLoading = true;
  int _totalSize = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadDownloads();

    // Listen for download updates using ChangeNotifier
    _downloadService.addListener(_onDownloadUpdate);
  }

  void _onDownloadUpdate() {
    if (mounted) {
      _loadDownloads(); // Also reloads list to update completed status
    }
  }

  @override
  void dispose() {
    _downloadService.removeListener(_onDownloadUpdate);
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDownloads() async {
    setState(() => _isLoading = true);

    final items = await _downloadService.getDownloadedItems();
    final totalSize = await _downloadService.getTotalDownloadSize();

    if (mounted) {
      setState(() {
        _downloads = items;
        _totalSize = totalSize;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDownload(DownloadedItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Excluir download?',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: Text(
          'O arquivo "${item.displayTitle}" será excluído permanentemente.',
          style: GoogleFonts.outfit(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.outfit(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Excluir',
              style: GoogleFonts.outfit(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _downloadService.deleteDownload(item);
      await _loadDownloads();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download excluído'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _playDownload(DownloadedItem item) {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloads não suportados na Web')),
      );
      return;
    }
    final file = io.File(item.localPath);
    if (file.existsSync()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              VideoPlayerScreen(videoUrl: item.localPath, isLocal: true),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Arquivo não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      _loadDownloads();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTasks = _downloadService.activeTasks;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Downloads',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_downloads.isNotEmpty || activeTasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _downloadService.formatFileSize(_totalSize),
                    style: GoogleFonts.outfit(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            )
          : (_downloads.isEmpty && activeTasks.isEmpty)
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadDownloads,
              color: AppColors.primaryRed,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Active Downloads Section
                  if (activeTasks.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Baixando agora',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...activeTasks.values.map(
                      (task) => _buildActiveDownloadItem(task),
                    ),
                    if (_downloads.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: Colors.grey),
                      ),
                  ],

                  // Completed Downloads
                  if (_downloads.isNotEmpty) ...[
                    _buildHeader(),
                    ..._downloads.map((item) => _buildDownloadItem(item)),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildActiveDownloadItem(DownloadTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.downloading, color: Colors.blue, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.item.title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () {
                  _downloadService.cancelDownload(task.id);
                  setState(() {});
                },
                icon: const Icon(Icons.close),
                color: Colors.red,
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: task.progress,
                    backgroundColor: Colors.grey[800],
                    valueColor: const AlwaysStoppedAnimation(Colors.blue),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(task.progress * 100).toStringAsFixed(1)}%',
                style: GoogleFonts.outfit(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            task.status.toString().split('.').last.toUpperCase(),
            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.download_rounded,
              size: 60,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum download',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Baixe filmes e episódios para assistir offline.\n\n⚠️ Aviso: Arquivos de vídeo podem ser grandes (500MB - 2GB)',
              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_downloads.length} ${_downloads.length == 1 ? 'item' : 'itens'} baixados',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_downloads.isNotEmpty)
            TextButton.icon(
              onPressed: _showClearAllDialog,
              icon: const Icon(Icons.delete_sweep, size: 18, color: Colors.red),
              label: Text(
                'Limpar tudo',
                style: GoogleFonts.outfit(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDownloadItem(DownloadedItem item) {
    bool exists = false;
    if (!kIsWeb) {
      final file = io.File(item.localPath);
      exists = file.existsSync();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: exists ? () => _playDownload(item) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 100,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                  image: item.logoUrl != null && item.logoUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(item.logoUrl!),
                          fit: BoxFit.cover,
                          onError: (_, __) {},
                        )
                      : null,
                ),
                child: Stack(
                  children: [
                    if (exists)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    if (item.isSeries)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'T${item.season}E${item.episode}',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayTitle,
                      style: GoogleFonts.outfit(
                        color: exists ? Colors.white : Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          exists ? Icons.check_circle : Icons.error,
                          color: exists ? Colors.green : Colors.red,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          exists
                              ? _downloadService.formatFileSize(item.fileSize)
                              : 'Arquivo não encontrado',
                          style: GoogleFonts.outfit(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete button
              IconButton(
                onPressed: () => _deleteDownload(item),
                icon: const Icon(Icons.delete_outline),
                color: Colors.grey,
                iconSize: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showClearAllDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Excluir todos os downloads?',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: Text(
          'Isso liberará ${_downloadService.formatFileSize(_totalSize)} de espaço.',
          style: GoogleFonts.outfit(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.outfit(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Excluir tudo',
              style: GoogleFonts.outfit(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      for (var item in _downloads) {
        await _downloadService.deleteDownload(item);
      }
      await _loadDownloads();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todos os downloads foram excluídos'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
