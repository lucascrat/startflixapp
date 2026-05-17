import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../services/tmdb_service.dart';
import '../services/m3u_service.dart';
import 'movie_details_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TmdbService _tmdbService = TmdbService();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _trendingMovies = [];
  List<Map<String, dynamic>> _trendingTv = [];
  List<Map<String, dynamic>> _popularMovies = [];
  List<Map<String, dynamic>> _topRatedMovies = [];
  List<Map<String, dynamic>> _topRatedTv = [];
  List<Map<String, dynamic>> _nowPlaying = [];
  List<Map<String, dynamic>> _upcoming = [];

  bool _isLoading = true;
  Map<String, dynamic>? _featuredItem;

  final M3uService _m3uService = M3uService();
  Set<String> _availableTitles = {};
  // Memoized availability: computed once per normalized title, not on every rebuild.
  final Map<String, bool> _availabilityCache = {};

  bool _isAvailable(String title) {
    if (title.isEmpty) return false;
    final normalized = M3uService.normalizeTitle(title);
    return _availabilityCache.putIfAbsent(normalized, () {
      return _availableTitles.any((it) {
        if (it.contains(normalized) || normalized.contains(it)) return true;
        final words = normalized.split(' ').where((w) => w.length > 3).toList();
        if (words.length >= 2) return words.every((w) => it.contains(w));
        return false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loadStaleFromMemory(); // Show cached content instantly, no spinner
    _loadData();            // Refresh in background, updates UI when done
  }

  /// Populate state from static in-memory cache synchronously.
  /// This means users see content immediately on revisit or when data is fresh.
  void _loadStaleFromMemory() {
    final trending = TmdbService.getStaleResults(
        'https://api.themoviedb.org/3/trending/movie/day?language=pt-BR');
    if (trending.isEmpty) return; // Nothing cached yet — _loadData will show spinner
    setState(() {
      _trendingMovies = trending;
      _trendingTv = TmdbService.getStaleResults(
          'https://api.themoviedb.org/3/trending/tv/day?language=pt-BR');
      _popularMovies = TmdbService.getStaleResults(
          'https://api.themoviedb.org/3/movie/popular?language=pt-BR&region=BR');
      _topRatedMovies = TmdbService.getStaleResults(
          'https://api.themoviedb.org/3/movie/top_rated?language=pt-BR&region=BR');
      _topRatedTv = TmdbService.getStaleResults(
          'https://api.themoviedb.org/3/tv/top_rated?language=pt-BR');
      _nowPlaying = TmdbService.getStaleResults(
          'https://api.themoviedb.org/3/movie/now_playing?language=pt-BR&region=BR');
      _upcoming = TmdbService.getStaleResults(
          'https://api.themoviedb.org/3/movie/upcoming?language=pt-BR&region=BR');
      _featuredItem = trending.isNotEmpty ? trending[0] : null;
      _isLoading = false;
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    // Show spinner only on first load (no stale data available yet)
    if (_trendingMovies.isEmpty) setState(() => _isLoading = true);

    final results = await Future.wait([
      _tmdbService.getTrendingMovies(),
      _tmdbService.getTrendingTvShows(),
      _tmdbService.getPopularMovies(),
      _tmdbService.getTopRatedMovies(),
      _tmdbService.getTopRatedTvShows(),
      _tmdbService.getNowPlayingMovies(),
      _tmdbService.getUpcomingMovies(),
      _m3uService.getCachedAvailableTitles(),
    ]);

    if (!mounted) return;

    // Clear memoized availability so it's recomputed with new M3U titles
    _availabilityCache.clear();

    setState(() {
      _trendingMovies = results[0] as List<Map<String, dynamic>>;
      _trendingTv = results[1] as List<Map<String, dynamic>>;
      _popularMovies = results[2] as List<Map<String, dynamic>>;
      _topRatedMovies = results[3] as List<Map<String, dynamic>>;
      _topRatedTv = results[4] as List<Map<String, dynamic>>;
      _nowPlaying = results[5] as List<Map<String, dynamic>>;
      _upcoming = results[6] as List<Map<String, dynamic>>;
      _availableTitles = Set<String>.from(results[7] as List<String>);
      if (_trendingMovies.isNotEmpty) _featuredItem = _trendingMovies[0];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primaryRed,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Featured Header
                  SliverToBoxAdapter(child: _buildFeaturedHeader()),

                  // Top 10 Movies
                  SliverToBoxAdapter(
                    child: _buildTop10Section(
                      'Top 10 Filmes no Brasil',
                      _trendingMovies.take(10).toList(),
                      isMovie: true,
                    ),
                  ),

                  // Trending TV
                  SliverToBoxAdapter(
                    child: _buildContentSection(
                      'Séries em Alta',
                      _trendingTv,
                      isMovie: false,
                      icon: Icons.trending_up,
                    ),
                  ),

                  // Popular Movies
                  SliverToBoxAdapter(
                    child: _buildContentSection(
                      'Populares',
                      _popularMovies,
                      isMovie: true,
                      icon: Icons.local_fire_department,
                    ),
                  ),

                  // Top 10 TV Shows
                  SliverToBoxAdapter(
                    child: _buildTop10Section(
                      'Top 10 Séries no Brasil',
                      _trendingTv.take(10).toList(),
                      isMovie: false,
                    ),
                  ),

                  // Now Playing
                  SliverToBoxAdapter(
                    child: _buildContentSection(
                      'Em Cartaz nos Cinemas',
                      _nowPlaying,
                      isMovie: true,
                      icon: Icons.movie,
                    ),
                  ),

                  // Top Rated Movies
                  SliverToBoxAdapter(
                    child: _buildContentSection(
                      'Mais Bem Avaliados',
                      _topRatedMovies,
                      isMovie: true,
                      icon: Icons.star,
                    ),
                  ),

                  // Upcoming
                  SliverToBoxAdapter(
                    child: _buildContentSection(
                      'Em Breve',
                      _upcoming,
                      isMovie: true,
                      icon: Icons.calendar_month,
                    ),
                  ),

                  // Top Rated TV
                  SliverToBoxAdapter(
                    child: _buildContentSection(
                      'Séries Mais Bem Avaliadas',
                      _topRatedTv,
                      isMovie: false,
                      icon: Icons.workspace_premium,
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
    );
  }

  Widget _buildFeaturedHeader() {
    if (_featuredItem == null) return const SizedBox.shrink();

    final backdrop = TmdbService.getBackdropUrl(
      _featuredItem!['backdrop_path'],
    );
    final title = _featuredItem!['title'] ?? _featuredItem!['name'] ?? '';
    final overview = _featuredItem!['overview'] ?? '';

    return Stack(
      children: [
        // Background Image
        ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Colors.black.withOpacity(0.8),
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.dstIn,
          child: Container(
            height: 550,
            decoration: BoxDecoration(
              image: backdrop.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(backdrop),
                      fit: BoxFit.cover,
                    )
                  : null,
              gradient: backdrop.isEmpty
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryRed.withOpacity(0.6),
                        Colors.black,
                      ],
                    )
                  : null,
            ),
          ),
        ),

        // Gradient overlay
        Container(
          height: 550,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.8),
                Colors.black,
              ],
              stops: const [0.0, 0.5, 0.8, 1.0],
            ),
          ),
        ),

        // Content
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo/Title
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Overview
              Text(
                overview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  // Play Button
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () => _openDetails(_featuredItem!, true),
                      icon: const Icon(Icons.play_arrow, size: 28),
                      label: Text(
                        'Assistir',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Info Button
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800]!.withOpacity(0.8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () => _openDetails(_featuredItem!, true),
                      icon: const Icon(Icons.info_outline, size: 24),
                      label: Text(
                        'Mais Infos',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // App Bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Text(
                    'STARTFLIX',
                    style: GoogleFonts.bebasNeue(
                      color: AppColors.primaryRed,
                      fontSize: 28,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTop10Section(
    String title,
    List<Map<String, dynamic>> items, {
    required bool isMovie,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    // Responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final titleFontSize = isSmallScreen ? 14.0 : 18.0;
    final listHeight = isSmallScreen ? 150.0 : 180.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            isSmallScreen ? 12 : 16,
            16,
            isSmallScreen ? 12 : 16,
            10,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 6 : 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'TOP 10',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 10 : 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.replaceAll('Top 10 ', ''),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: listHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildTop10Card(items[index], index + 1, isMovie);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTop10Card(Map<String, dynamic> item, int rank, bool isMovie) {
    final poster = TmdbService.getPosterUrl(item['poster_path']);

    // Responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final cardWidth = isSmallScreen ? 110.0 : 140.0;
    final rankFontSize = isSmallScreen ? 90.0 : 120.0;

    return GestureDetector(
      onTap: () => _openDetails(item, isMovie),
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Rank Number
            Positioned(
              left: -20,
              bottom: 0,
              child: Text(
                '$rank',
                style: GoogleFonts.bebasNeue(
                  color: Colors.black,
                  fontSize: rankFontSize,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: AppColors.primaryRed,
                      blurRadius: 0,
                      offset: const Offset(3, 3),
                    ),
                  ],
                ),
              ),
            ),

            // Poster
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 100,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(5, 5),
                    ),
                  ],
                  image: poster.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(poster),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: poster.isEmpty ? Colors.grey[800] : null,
                ),
                child: poster.isEmpty
                    ? const Icon(Icons.movie, color: Colors.white54, size: 40)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(
    String title,
    List<Map<String, dynamic>> items, {
    required bool isMovie,
    IconData? icon,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    // Responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final titleFontSize = isSmallScreen ? 14.0 : 18.0;
    final iconSize = isSmallScreen ? 18.0 : 22.0;
    final listHeight = isSmallScreen ? 170.0 : 200.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            isSmallScreen ? 12 : 16,
            20,
            isSmallScreen ? 8 : 16,
            10,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.primaryRed, size: iconSize),
                SizedBox(width: isSmallScreen ? 6 : 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isSmallScreen)
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Text(
                        'Ver Tudo',
                        style: GoogleFonts.outfit(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 16,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: listHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildContentCard(items[index], isMovie);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard(Map<String, dynamic> item, bool isMovie) {
    final poster = TmdbService.getPosterUrl(item['poster_path']);
    final title = item['title'] ?? item['name'] ?? '';
    final rating = (item['vote_average'] ?? 0).toDouble();

    final isAvailable = _isAvailable(title);

    return GestureDetector(
      onTap: () => _openDetails(item, isMovie),
      child: Container(
        width: 130,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: poster.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(poster),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: poster.isEmpty ? Colors.grey[800] : null,
                ),
                child: Stack(
                  children: [
                    // Availability Badge
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? Colors.green.withOpacity(0.9)
                              : Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isAvailable
                                ? Colors.green
                                : Colors.grey.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isAvailable
                                  ? Icons.play_arrow
                                  : Icons.lock_outline,
                              color: Colors.white,
                              size: 10,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAvailable ? 'ASSISTIR' : 'INDISPONÍVEL',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Rating Badge
                    if (rating > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getRatingColor(rating),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                rating.toStringAsFixed(1),
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Placeholder
                    if (poster.isEmpty)
                      const Center(
                        child: Icon(
                          Icons.movie,
                          color: Colors.white54,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 7.5) return Colors.green;
    if (rating >= 6.0) return Colors.orange;
    return Colors.red;
  }

  void _openDetails(Map<String, dynamic> item, bool isMovie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(item: item, isMovie: isMovie),
      ),
    );
  }
}
