import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';

class LocalPlayerScreen extends StatefulWidget {
  const LocalPlayerScreen({super.key});

  @override
  State<LocalPlayerScreen> createState() => _LocalPlayerScreenState();
}

class _LocalPlayerScreenState extends State<LocalPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isPlaying = false;
  String? _currentVideoPath;
  String? _currentVideoName;
  List<Map<String, String>> _recentVideos = [];
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _loadRecentVideos();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _loadRecentVideos() async {
    // TODO: Load from SharedPreferences
    setState(() {});
  }

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          await _playVideo(file.path!, file.name);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar vídeo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _playVideo(String path, String name) async {
    // Dispose previous controllers
    _videoController?.dispose();
    _chewieController?.dispose();

    setState(() {
      _currentVideoPath = path;
      _currentVideoName = name;
      _isPlaying = true;
    });

    // Initialize video controller
    if (kIsWeb) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(path));
    } else {
      _videoController = VideoPlayerController.file(io.File(path));
    }

    try {
      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        showControls: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primaryRed),
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
                  'Erro ao reproduzir',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      // Add to recent videos
      _addToRecent(path, name);

      setState(() {});
    } catch (e) {
      setState(() => _isPlaying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao reproduzir vídeo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addToRecent(String path, String name) {
    _recentVideos.removeWhere((v) => v['path'] == path);
    _recentVideos.insert(0, {'path': path, 'name': name});
    if (_recentVideos.length > 10) {
      _recentVideos = _recentVideos.sublist(0, 10);
    }
    // TODO: Save to SharedPreferences
  }

  void _enterFullscreen() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    setState(() => _isFullscreen = true);
  }

  void _exitFullscreen() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    setState(() => _isFullscreen = false);
  }

  void _stopVideo() {
    _videoController?.pause();
    _videoController?.dispose();
    _chewieController?.dispose();
    _videoController = null;
    _chewieController = null;
    _exitFullscreen();
    setState(() {
      _isPlaying = false;
      _currentVideoPath = null;
      _currentVideoName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isPlaying && _isFullscreen) {
      return WillPopScope(
        onWillPop: () async {
          _exitFullscreen();
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: _buildFullscreenPlayer(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Video Player or Video Picker
            Expanded(
              child: _isPlaying ? _buildPlayerView() : _buildPickerView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryRed,
                  AppColors.primaryRed.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.play_circle_fill,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'StartFlix Player',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Reprodutor de Vídeo Local',
                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          // Settings button
          IconButton(
            onPressed: () => _showSettings(),
            icon: const Icon(Icons.settings, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Main action card
          _buildSelectVideoCard(),

          const SizedBox(height: 24),

          // Recent videos
          if (_recentVideos.isNotEmpty) _buildRecentVideos(),

          // Features
          const SizedBox(height: 24),
          _buildFeaturesSection(),
        ],
      ),
    );
  }

  Widget _buildSelectVideoCard() {
    return GestureDetector(
      onTap: _pickVideo,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryRed.withOpacity(0.2), Colors.black],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primaryRed.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open,
                size: 64,
                color: AppColors.primaryRed,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Selecionar Vídeo',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha um vídeo do seu dispositivo para reproduzir',
              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.video_library, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Abrir Galeria',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentVideos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reproduzidos Recentemente',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _recentVideos.clear());
              },
              child: Text(
                'Limpar',
                style: GoogleFonts.outfit(color: Colors.grey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_recentVideos.length, (index) {
          final video = _recentVideos[index];
          return _buildRecentVideoItem(video['path']!, video['name']!);
        }),
      ],
    );
  }

  Widget _buildRecentVideoItem(String path, String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () {
          if (kIsWeb) {
            _playVideo(path, name);
            return;
          }
          final file = io.File(path);
          if (file.existsSync()) {
            _playVideo(path, name);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Arquivo não encontrado'),
                backgroundColor: Colors.orange,
              ),
            );
            setState(() {
              _recentVideos.removeWhere((v) => v['path'] == path);
            });
          }
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.movie, color: Colors.grey),
        ),
        title: Text(
          name,
          style: GoogleFonts.outfit(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          path.split('/').last,
          style: GoogleFonts.outfit(color: Colors.grey, fontSize: 11),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.play_circle, color: AppColors.primaryRed),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      {
        'icon': Icons.hd,
        'title': 'Alta Qualidade',
        'desc': 'Suporte a vídeos HD e 4K',
      },
      {
        'icon': Icons.speed,
        'title': 'Velocidade',
        'desc': 'Controle de velocidade de reprodução',
      },
      {
        'icon': Icons.subtitles,
        'title': 'Legendas',
        'desc': 'Suporte a legendas externas',
      },
      {
        'icon': Icons.fullscreen,
        'title': 'Tela Cheia',
        'desc': 'Modo imersivo horizontal',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recursos do Player',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    feature['icon'] as IconData,
                    color: AppColors.primaryRed,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feature['title'] as String,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    feature['desc'] as String,
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlayerView() {
    return Column(
      children: [
        // Video info bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.grey[900],
          child: Row(
            children: [
              const Icon(Icons.movie, color: AppColors.primaryRed),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _currentVideoName ?? 'Vídeo',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: _enterFullscreen,
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                tooltip: 'Tela Cheia',
              ),
              IconButton(
                onPressed: _stopVideo,
                icon: const Icon(Icons.close, color: Colors.grey),
                tooltip: 'Fechar',
              ),
            ],
          ),
        ),

        // Video player
        Expanded(
          child: Container(
            color: Colors.black,
            child:
                _chewieController != null &&
                    _videoController!.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryRed,
                    ),
                  ),
          ),
        ),

        // Bottom controls
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[900],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(Icons.folder_open, 'Outro Vídeo', _pickVideo),
              _buildControlButton(
                Icons.fullscreen,
                'Tela Cheia',
                _enterFullscreen,
              ),
              _buildControlButton(Icons.stop, 'Parar', _stopVideo),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildFullscreenPlayer() {
    return Stack(
      children: [
        // Video
        Center(
          child:
              _chewieController != null && _videoController!.value.isInitialized
              ? Chewie(controller: _chewieController!)
              : const CircularProgressIndicator(color: AppColors.primaryRed),
        ),

        // Exit fullscreen button
        Positioned(
          top: 16,
          left: 16,
          child: SafeArea(
            child: IconButton(
              onPressed: _exitFullscreen,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fullscreen_exit, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configurações do Player',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.history, color: AppColors.primaryRed),
              title: Text(
                'Limpar Histórico',
                style: GoogleFonts.outfit(color: Colors.white),
              ),
              subtitle: Text(
                'Remove os vídeos recentes',
                style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
              ),
              onTap: () {
                setState(() => _recentVideos.clear());
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.grey),
              title: Text(
                'Sobre',
                style: GoogleFonts.outfit(color: Colors.white),
              ),
              subtitle: Text(
                'StartFlix Player v1.0',
                style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
              ),
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                'Sair da Conta',
                style: GoogleFonts.outfit(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                Navigator.pop(context); // Close modal
                await _logout();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      // Assuming AuthService is available globally or we instantiate it
      // We need to import auth_service.dart first
      final supabase = Supabase.instance.client;
      await supabase.auth.signOut();

      if (mounted) {
        // Force reload of the app or navigation
        // Since MainTabScreen controls the state, we might need to rely on the AuthGate stream
        // But to be sure, we can restart the app structure or just wait for the stream listener
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao sair: $e")));
      }
    }
  }
}
