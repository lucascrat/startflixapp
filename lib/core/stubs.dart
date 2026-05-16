// Stubs for Web compatibility
import 'package:flutter/material.dart';

// flutter_downloader stubs
class FlutterDownloader {
  static Future<void> initialize({
    bool debug = true,
    bool ignoreSsl = false,
  }) async {}
  static Future<void> registerCallback(dynamic callback) async {}
  static Future<String?> enqueue({
    required String url,
    required String savedDir,
    String? fileName,
    bool showNotification = true,
    bool openFileFromNotification = true,
  }) async => null;
  static Future<void> cancel({required String taskId}) async {}
  static Future<void> remove({
    required String taskId,
    bool shouldDeleteContent = false,
  }) async {}
  static Future<List<dynamic>?> loadTasks() async => null;
}

enum DownloadTaskStatus {
  undefined,
  enqueued,
  running,
  complete,
  failed,
  canceled,
  paused,
}

// youtube_player_flutter stubs
class YoutubePlayerController {
  YoutubePlayerController({required String initialVideoId, dynamic flags});
  void dispose() {}
  void pause() {}
  void play() {}
  dynamic get value => null;
}

class YoutubePlayerFlags {
  const YoutubePlayerFlags({
    this.autoPlay = true,
    this.mute = false,
    this.isLive = false,
    this.forceHD = false,
    this.enableCaption = true,
    this.captionLanguage = 'en',
    this.hideControls = false,
    this.controlsVisibleAtStart = false,
    this.disableDragSeek = false,
    this.hideThumbnail = false,
    this.loop = false,
  });
  final bool autoPlay;
  final bool mute;
  final bool isLive;
  final bool forceHD;
  final bool enableCaption;
  final String captionLanguage;
  final bool hideControls;
  final bool controlsVisibleAtStart;
  final bool disableDragSeek;
  final bool hideThumbnail;
  final bool loop;
}

class YoutubePlayer extends StatelessWidget {
  final dynamic controller;
  final double? aspectRatio;
  final dynamic showVideoProgressIndicator;
  final dynamic progressIndicatorColor;
  final dynamic onReady;

  const YoutubePlayer({
    super.key,
    required this.controller,
    this.aspectRatio,
    this.showVideoProgressIndicator,
    this.progressIndicatorColor,
    this.onReady,
  });

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('YouTube not supported on Web in this player'));
}

class YoutubePlayerBuilder extends StatelessWidget {
  final Widget player;
  final Widget Function(BuildContext, Widget) builder;

  const YoutubePlayerBuilder({
    super.key,
    required this.player,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) => builder(context, player);
}
