import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';
import '../services/tmdb_service.dart';
import '../services/m3u_service.dart';

import '../services/ad_service.dart';
import '../models/media_item.dart';
import 'video_player_screen.dart';
import 'series_detail_screen.dart';
import '../services/download_service.dart';

// Schema name for Supabase queries
const String _supabaseSchema = 'startflix';

// Helper to get table with schema
SupabaseQueryBuilder _fromTable(String table) =>
    Supabase.instance.client.schema(_supabaseSchema).from(table);

class MovieDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isMovie;

  const MovieDetailsScreen({
    super.key,
    required this.item,
    required this.isMovie,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final TmdbService _tmdbService = TmdbService();
  final M3uService _m3uService = M3uService();

  Map<String, dynamic>? _details;
  bool _isLoading = true;

  // M3U Integration
  MediaItem? _m3uMatch;
  List<MediaItem> _allSeriesEpisodes = [];
  bool _searchingM3u = false;

  // Watchlist
  bool _isInWatchlist = false;
  bool _watchlistLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
    _checkWatchlist();

    // Listen for download progress using ChangeNotifier
    DownloadService().addListener(_onDownloadUpdate);
  }

  void _onDownloadUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    DownloadService().removeListener(_onDownloadUpdate);
    super.dispose();
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);

    final id = widget.item['id'];
    if (id != null) {
      if (widget.isMovie) {
        _details = await _tmdbService.getMovieDetails(id);
      } else {
        _details = await _tmdbService.getTvShowDetails(id);
      }
    }

    setState(() => _isLoading = false);

    // Search for M3U match
    _searchM3uContent();
  }

  Future<void> _searchM3uContent() async {
    setState(() => _searchingM3u = true);

    try {
      final title =
          (_details?['title'] ??
                  _details?['name'] ??
                  widget.item['title'] ??
                  widget.item['name'] ??
                  '')
              .toString();

      if (title.isEmpty) {
        setState(() => _searchingM3u = false);
        return;
      }

      // 1. Search for match using the optimized service (powered by cache)
      final match = await _m3uService.searchMatch(title);

      // 2. If it's a series, we might want to find all episodes
      List<MediaItem> allMatches = [];
      if (!widget.isMovie && match != null) {
        // Use centralized URL retrieval for consistency and security
        final url = await _m3uService.getUserM3uUrl();
        if (url != null) {
          final items = await _m3uService.getCachedM3uItems(url);
          if (items != null) {
            final searchTitle = title.toLowerCase();
            allMatches = items
                .where((item) => item.title.toLowerCase().contains(searchTitle))
                .toList();
          }
        }
      }

      if (mounted) {
        setState(() {
          _m3uMatch = match;
          _allSeriesEpisodes = allMatches;
          _searchingM3u = false;
        });
      }
    } catch (e) {
      print('Error searching M3U in details: $e');
      if (mounted) {
        setState(() => _searchingM3u = false);
      }
    }
  }

  Future<void> _checkWatchlist() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final tmdbId = widget.item['id'];
      if (tmdbId == null) return;

      final response = await Supabase.instance.client
          .from('user_watchlist')
          .select('id')
          .eq('user_id', userId)
          .eq('tmdb_id', tmdbId)
          .eq('media_type', widget.isMovie ? 'movie' : 'tv')
          .maybeSingle();

      if (mounted) {
        setState(() => _isInWatchlist = response != null);
      }
    } catch (e) {
      print('Error checking watchlist: $e');
    }
  }

  Future<void> _toggleWatchlist() async {
    setState(() => _watchlistLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faça login para usar esta função')),
        );
        return;
      }

      final tmdbId = widget.item['id'];
      final title =
          _details?['title'] ??
          _details?['name'] ??
          widget.item['title'] ??
          widget.item['name'] ??
          '';

      if (_isInWatchlist) {
        // Remove from watchlist
        await Supabase.instance.client
            .from('user_watchlist')
            .delete()
            .eq('user_id', userId)
            .eq('tmdb_id', tmdbId)
            .eq('media_type', widget.isMovie ? 'movie' : 'tv');

        if (mounted) {
          setState(() => _isInWatchlist = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removido da sua lista'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // Add to watchlist
        await _fromTable('user_watchlist').insert({
          'user_id': userId,
          'tmdb_id': tmdbId,
          'media_type': widget.isMovie ? 'movie' : 'tv',
          'title': title,
          'poster_path': _details?['poster_path'] ?? widget.item['poster_path'],
          'backdrop_path':
              _details?['backdrop_path'] ?? widget.item['backdrop_path'],
          'overview': _details?['overview'] ?? widget.item['overview'],
          'vote_average':
              _details?['vote_average'] ?? widget.item['vote_average'],
          'release_date':
              _details?['release_date'] ??
              _details?['first_air_date'] ??
              widget.item['release_date'] ??
              widget.item['first_air_date'],
        });

        if (mounted) {
          setState(() => _isInWatchlist = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Adicionado à sua lista!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _watchlistLoading = false);
      }
    }
  }

  void _playM3uContent() {
    if (_m3uMatch == null) return;

    // If it's a TV show and we have episodes, open series detail screen
    if (!widget.isMovie && _allSeriesEpisodes.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SeriesDetailScreen(
            seriesName: _m3uMatch!.title,
            episodes: _allSeriesEpisodes,
            logoUrl: _m3uMatch!.logoUrl,
          ),
        ),
      );
    } else {
      // For movies or single episodes, play directly
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(videoUrl: _m3uMatch!.url),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final backdrop = TmdbService.getBackdropUrl(
      _details?['backdrop_path'] ?? widget.item['backdrop_path'],
    );
    final poster = TmdbService.getPosterUrl(
      _details?['poster_path'] ?? widget.item['poster_path'],
    );
    final title =
        _details?['title'] ??
        _details?['name'] ??
        widget.item['title'] ??
        widget.item['name'] ??
        '';
    final overview = _details?['overview'] ?? widget.item['overview'] ?? '';
    final rating =
        (_details?['vote_average'] ?? widget.item['vote_average'] ?? 0)
            .toDouble();
    final releaseDate =
        _details?['release_date'] ??
        _details?['first_air_date'] ??
        widget.item['release_date'] ??
        '';
    final runtime = _details?['runtime'] ?? 0;
    final genres = _details?['genres'] as List? ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            )
          : CustomScrollView(
              slivers: [
                // Header with backdrop
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      // Backdrop
                      ShaderMask(
                        shaderCallback: (rect) {
                          return LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black, Colors.transparent],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.dstIn,
                        child: Container(
                          height: 400,
                          decoration: BoxDecoration(
                            image: backdrop.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(backdrop),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color: backdrop.isEmpty ? Colors.grey[900] : null,
                          ),
                        ),
                      ),

                      // Gradient overlay
                      Container(
                        height: 400,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                              Colors.black,
                            ],
                            stops: const [0.3, 0.7, 1.0],
                          ),
                        ),
                      ),

                      // Back button
                      Positioned(
                        top: 50,
                        left: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),

                      // Content at bottom
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Poster
                              Container(
                                width: 120,
                                height: 180,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 15,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                  image: poster.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(poster),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  color: poster.isEmpty
                                      ? Colors.grey[800]
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Title and info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        // Rating
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getRatingColor(rating),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                rating.toStringAsFixed(1),
                                                style: GoogleFonts.outfit(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),

                                        // Year
                                        if (releaseDate.isNotEmpty)
                                          Text(
                                            releaseDate.substring(0, 4),
                                            style: GoogleFonts.outfit(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),

                                        // Runtime
                                        if (runtime > 0) ...[
                                          const SizedBox(width: 10),
                                          Text(
                                            '${runtime}min',
                                            style: GoogleFonts.outfit(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // M3U Status indicator
                        if (_searchingM3u)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Buscando na sua lista...',
                                  style: GoogleFonts.outfit(color: Colors.blue),
                                ),
                              ],
                            ),
                          ),

                        if (_m3uMatch != null && !_searchingM3u)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Encontrado: ${_m3uMatch!.title}',
                                    style: GoogleFonts.outfit(
                                      color: Colors.green,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (_m3uMatch == null && !_searchingM3u)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Não encontrado na sua lista M3U',
                                    style: GoogleFonts.outfit(
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Play button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _m3uMatch != null
                                  ? AppColors.primaryRed
                                  : Colors.grey[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _m3uMatch != null
                                ? _playM3uContent
                                : null,
                            icon: const Icon(
                              Icons.play_arrow,
                              size: 28,
                              color: Colors.white,
                            ),
                            label: Text(
                              _m3uMatch != null
                                  ? 'Assistir Agora'
                                  : 'Indisponível',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Download section for movies
                        if (widget.isMovie && _m3uMatch != null)
                          _buildDownloadSection(),

                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _watchlistLoading
                                  ? const Center(
                                      child: SizedBox(
                                        height: 40,
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryRed,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: _isInWatchlist
                                            ? AppColors.primaryRed
                                            : Colors.white,
                                        backgroundColor: _isInWatchlist
                                            ? AppColors.primaryRed.withOpacity(
                                                0.1,
                                              )
                                            : null,
                                        side: BorderSide(
                                          color: _isInWatchlist
                                              ? AppColors.primaryRed
                                              : Colors.grey,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: _toggleWatchlist,
                                      icon: Icon(
                                        _isInWatchlist
                                            ? Icons.check
                                            : Icons.add,
                                        size: 22,
                                      ),
                                      label: Text(
                                        _isInWatchlist
                                            ? 'Na Lista'
                                            : 'Minha Lista',
                                        style: GoogleFonts.outfit(),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.grey),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {},
                                icon: const Icon(Icons.share, size: 20),
                                label: Text(
                                  'Compartilhar',
                                  style: GoogleFonts.outfit(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Genres
                        if (genres.isNotEmpty) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: genres.map<Widget>((genre) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  genre['name'] ?? '',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Overview
                        Text(
                          'Sinopse',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          overview.isNotEmpty
                              ? overview
                              : 'Sinopse não disponível.',
                          style: GoogleFonts.outfit(
                            color: Colors.grey[300],
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Cast
                        if (_details?['credits']?['cast'] != null) ...[
                          Text(
                            'Elenco',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 140,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: (_details!['credits']['cast'] as List)
                                  .take(10)
                                  .length,
                              itemBuilder: (context, index) {
                                final cast =
                                    _details!['credits']['cast'][index];
                                final profilePath = TmdbService.getPosterUrl(
                                  cast['profile_path'],
                                  size: 'w185',
                                );

                                return Container(
                                  width: 80,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: profilePath.isNotEmpty
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                    profilePath,
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                          color: profilePath.isEmpty
                                              ? Colors.grey[800]
                                              : null,
                                        ),
                                        child: profilePath.isEmpty
                                            ? const Icon(
                                                Icons.person,
                                                color: Colors.grey,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        cast['name'] ?? '',
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        cast['character'] ?? '',
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.outfit(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],

                        // Similar
                        if (_details?['similar']?['results'] != null &&
                            (_details!['similar']['results'] as List)
                                .isNotEmpty) ...[
                          const SizedBox(height: 30),
                          Text(
                            'Títulos Semelhantes',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  (_details!['similar']['results'] as List)
                                      .take(10)
                                      .length,
                              itemBuilder: (context, index) {
                                final similar =
                                    _details!['similar']['results'][index];
                                final similarPoster = TmdbService.getPosterUrl(
                                  similar['poster_path'],
                                );

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MovieDetailsScreen(
                                              item: similar,
                                              isMovie: widget.isMovie,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: similarPoster.isNotEmpty
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                similarPoster,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      color: similarPoster.isEmpty
                                          ? Colors.grey[800]
                                          : null,
                                    ),
                                    child: similarPoster.isEmpty
                                        ? const Icon(
                                            Icons.movie,
                                            color: Colors.grey,
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],

                        // Native Ad
                        const SizedBox(height: 20),
                        const NativeAdWidget(),

                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDownloadSection() {
    if (_m3uMatch == null) return const SizedBox.shrink();

    final isDownloading = DownloadService().isDownloading(_m3uMatch!.title);
    final progress = DownloadService().getProgress(_m3uMatch!.title);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.download_for_offline, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDownloading ? 'Baixando...' : 'Download disponível',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isDownloading) ...[
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[800],
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.primaryRed,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isDownloading)
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () => _downloadMovie(),
              child: const Text('Baixar'),
            ),
        ],
      ),
    );
  }

  Future<void> _downloadMovie() async {
    if (_m3uMatch == null) return;

    final hasPermission = await DownloadService().requestPermissions();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Permissão necessária')));
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Iniciando download de: ${_m3uMatch!.title}'),
        backgroundColor: Colors.blue,
      ),
    );

    await DownloadService().startDownload(_m3uMatch!);
    setState(() {});
  }

  Color _getRatingColor(double rating) {
    if (rating >= 7.5) return Colors.green;
    if (rating >= 6.0) return Colors.orange;
    return Colors.red;
  }
}
