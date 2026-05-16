import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../models/media_item.dart';
import '../services/download_service.dart';
import 'video_player_screen.dart';

class SeriesDetailScreen extends StatefulWidget {
  final String seriesName;
  final List<MediaItem> episodes;
  final String? logoUrl;

  const SeriesDetailScreen({
    super.key,
    required this.seriesName,
    required this.episodes,
    this.logoUrl,
  });

  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen> {
  final DownloadService _downloadService = DownloadService();

  late Map<int, List<MediaItem>> _seasonEpisodes;
  late List<int> _seasons;
  int _selectedSeason = 1;

  @override
  void initState() {
    super.initState();
    _organizeEpisodes();

    // Listen for download updates
    _downloadService.addListener(_onDownloadUpdate);
  }

  void _onDownloadUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _downloadService.removeListener(_onDownloadUpdate);
    super.dispose();
  }

  void _organizeEpisodes() {
    _seasonEpisodes = {};

    for (var episode in widget.episodes) {
      final season = episode.season ?? 1;
      if (!_seasonEpisodes.containsKey(season)) {
        _seasonEpisodes[season] = [];
      }
      _seasonEpisodes[season]!.add(episode);
    }

    // Sort episodes within each season
    for (var season in _seasonEpisodes.keys) {
      _seasonEpisodes[season]!.sort((a, b) {
        final epA = a.episode ?? 0;
        final epB = b.episode ?? 0;
        return epA.compareTo(epB);
      });
    }

    // Get sorted list of seasons
    _seasons = _seasonEpisodes.keys.toList()..sort();

    if (_seasons.isNotEmpty) {
      _selectedSeason = _seasons.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // App Bar with series poster
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.width < 360 ? 220 : 280,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  if (widget.logoUrl != null && widget.logoUrl!.isNotEmpty)
                    Image.network(
                      widget.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[900],
                        child: const Icon(
                          Icons.tv,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryRed.withOpacity(0.6),
                            Colors.black,
                          ],
                        ),
                      ),
                    ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                          Colors.black,
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
                  ),
                  // Title at bottom
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.seriesName,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryRed,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${_seasons.length} Temporada${_seasons.length > 1 ? 's' : ''}',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${widget.episodes.length} Episódios',
                              style: GoogleFonts.outfit(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Season selector
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _seasons.length,
                itemBuilder: (context, index) {
                  final season = _seasons[index];
                  final isSelected = season == _selectedSeason;
                  final episodesCount = _seasonEpisodes[season]?.length ?? 0;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSeason = season),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryRed
                            : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryRed
                              : Colors.grey[700]!,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          children: [
                            Text(
                              'T$season',
                              style: GoogleFonts.outfit(
                                color: isSelected ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '($episodesCount eps)',
                              style: GoogleFonts.outfit(
                                color: isSelected
                                    ? Colors.white70
                                    : Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Season header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.play_circle,
                    color: AppColors.primaryRed,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Temporada $_selectedSeason',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_seasonEpisodes[_selectedSeason]?.length ?? 0} episódios',
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          // Episodes list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final episodes = _seasonEpisodes[_selectedSeason] ?? [];
                if (index >= episodes.length) return null;
                return _buildEpisodeCard(episodes[index], index);
              }, childCount: (_seasonEpisodes[_selectedSeason] ?? []).length),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildEpisodeCard(MediaItem episode, int index) {
    final episodeNumber = episode.episode ?? (index + 1);

    // Responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final thumbWidth = isSmallScreen ? 100.0 : 120.0;
    final thumbHeight = isSmallScreen ? 65.0 : 75.0;
    final titleSize = isSmallScreen ? 13.0 : 15.0;

    return GestureDetector(
      onTap: () => _playEpisode(episode),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Episode thumbnail/number
            Container(
              width: thumbWidth,
              height: thumbHeight,
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                image: episode.logoUrl != null && episode.logoUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(episode.logoUrl!),
                        fit: BoxFit.cover,
                        onError: (_, __) {},
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  // Episode number overlay
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'E${episodeNumber.toString().padLeft(2, '0')}',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Play icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Episode info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Episódio $episodeNumber',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getEpisodeTitle(episode),
                      style: GoogleFonts.outfit(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Download button
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _buildDownloadButton(episode),
            ),

            // Play button
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton(MediaItem episode) {
    final progress = _downloadService.getProgress(episode.title);
    final isDownloading = _downloadService.isDownloading(episode.title);

    if (isDownloading) {
      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              value: progress > 0 ? progress : null,
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryRed),
            ),
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return IconButton(
      onPressed: () => _downloadEpisode(episode),
      icon: const Icon(Icons.download),
      color: Colors.grey[400],
      iconSize: 22,
      tooltip: 'Baixar episódio',
    );
  }

  Future<void> _downloadEpisode(MediaItem episode) async {
    // Request permissions
    final hasPermission = await _downloadService.requestPermissions();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissão de armazenamento necessária'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Start download
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Iniciando download: ${episode.title} em segundo plano...',
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    final taskId = await _downloadService.startDownload(episode);

    if (mounted) {
      if (taskId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download iniciado! Verifique a aba Downloads.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  String _getEpisodeTitle(MediaItem episode) {
    // Try to extract a meaningful episode title
    var title = episode.title;

    // Remove season/episode patterns from title
    title = title.replaceAll(
      RegExp(r'S\d{1,2}E\d{1,3}', caseSensitive: false),
      '',
    );
    title = title.replaceAll(RegExp(r'\d{1,2}x\d{1,3}'), '');
    title = title.replaceAll(widget.seriesName, '');
    title = title.replaceAll(RegExp(r'[-:|]+\s*$'), '').trim();
    title = title.replaceAll(RegExp(r'^\s*[-:|]+'), '').trim();

    if (title.isEmpty || title == widget.seriesName) {
      return 'S${_selectedSeason.toString().padLeft(2, '0')}E${(episode.episode ?? 1).toString().padLeft(2, '0')}';
    }

    return title;
  }

  void _playEpisode(MediaItem episode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoUrl: episode.url),
      ),
    );
  }
}
