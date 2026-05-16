import 'dart:io' as io;
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final bool isLocal;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    this.isLocal = false,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  // Standard Player
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  // YouTube Player
  YoutubePlayerController? _youtubeController;
  bool _isYoutube = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _enterFullscreen();
    _initializePlayer();
  }

  void _enterFullscreen() {
    // Force landscape orientation and hide system UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  void _exitFullscreen() {
    // Restore portrait orientation and system UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
  }

  Future<void> _initializePlayer() async {
    // Check if YouTube (remote Only)
    if (!widget.isLocal &&
        (widget.videoUrl.contains('youtube.com') ||
            widget.videoUrl.contains('youtu.be'))) {
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      if (videoId != null) {
        _isYoutube = true;
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            enableCaption: false,
            loop: false,
            forceHD: true,
          ),
        );
        setState(() {});
        return;
      }
    }

    // Standard Player (M3U / MP4 / HLS / File)
    if (widget.isLocal) {
      if (kIsWeb) {
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
        );
      } else {
        _videoPlayerController = VideoPlayerController.file(
          io.File(widget.videoUrl),
        );
      }
    } else {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        httpHeaders: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );
    }

    await _videoPlayerController.initialize();

    // Restore "Continue Watching" position
    final prefs = await SharedPreferences.getInstance();
    final String key = 'save_pos_${widget.videoUrl}';
    final int? savedSeconds = prefs.getInt(key);
    if (savedSeconds != null && savedSeconds > 0) {
      if (_videoPlayerController.value.duration > Duration.zero) {
        if (savedSeconds <
            _videoPlayerController.value.duration.inSeconds - 5) {
          await _videoPlayerController.seekTo(Duration(seconds: savedSeconds));
        }
      }
    }

    if (_isDisposed) return;

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      fullScreenByDefault: true,
      showControls: true,
      showOptions: false,
      allowMuting: true,
      allowPlaybackSpeedChanging: true,
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      ),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar vídeo',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
    setState(() {});
  }

  @override
  void dispose() {
    _isDisposed = true;
    _exitFullscreen();
    if (_isYoutube) {
      _youtubeController?.dispose();
    } else {
      try {
        if (_videoPlayerController.value.isInitialized &&
            _videoPlayerController.value.duration > Duration.zero) {
          final int currentSeconds =
              _videoPlayerController.value.position.inSeconds;
          SharedPreferences.getInstance().then((prefs) {
            prefs.setInt('save_pos_${widget.videoUrl}', currentSeconds);
          });
        }
      } catch (e) {
        print("Error saving progress: $e");
      }

      _videoPlayerController.dispose();
      _chewieController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isYoutube) {
      if (_youtubeController == null) {
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Colors.red)),
        );
      }
      return WillPopScope(
        onWillPop: () async {
          _exitFullscreen();
          return true;
        },
        child: YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: _youtubeController!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.red,
          ),
          builder: (context, player) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: SafeArea(
                child: Stack(
                  children: [
                    Center(child: player),
                    // Back button
                    Positioned(
                      top: 8,
                      left: 8,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          _exitFullscreen();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        _exitFullscreen();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child:
              _chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized
              ? Stack(
                  children: [
                    Chewie(controller: _chewieController!),
                    // Back button overlay
                    Positioned(
                      top: 8,
                      left: 8,
                      child: SafeArea(
                        child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          onPressed: () {
                            _exitFullscreen();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : const CircularProgressIndicator(color: Colors.red),
        ),
      ),
    );
  }
}
