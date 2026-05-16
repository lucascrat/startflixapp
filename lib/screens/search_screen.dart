import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../services/tmdb_service.dart';
import '../services/m3u_service.dart';
import 'movie_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TmdbService _tmdbService = TmdbService();

  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _trendingItems = [];
  bool _isSearching = false;
  bool _isLoading = false;

  final M3uService _m3uService = M3uService();
  List<String> _availableTitles = [];

  @override
  void initState() {
    super.initState();
    _loadTrending();
    _loadAvailableTitles();
  }

  Future<void> _loadAvailableTitles() async {
    final titles = await _m3uService.getCachedAvailableTitles();
    if (mounted) {
      setState(() {
        _availableTitles = titles;
      });
    }
  }

  Future<void> _loadTrending() async {
    final movies = await _tmdbService.getTrendingMovies();
    final tv = await _tmdbService.getTrendingTvShows();

    if (!mounted) return;
    setState(() {
      _trendingItems = [...movies.take(5), ...tv.take(5)];
    });
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.isEmpty) {
      if (!mounted) return;
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isSearching = true;
      _isLoading = true;
    });

    final results = await _tmdbService.searchMulti(query);

    if (!mounted) return;
    setState(() {
      _searchResults = results.where((item) {
        return item['media_type'] == 'movie' || item['media_type'] == 'tv';
      }).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.outfit(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Pesquisar filmes, séries...',
              hintStyle: GoogleFonts.outfit(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
      ),
      body: _isSearching ? _buildSearchResults() : _buildTrendingSection(),
    );
  }

  Widget _buildTrendingSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.trending_up, color: AppColors.primaryRed),
                const SizedBox(width: 8),
                Text(
                  'Pesquisas Populares',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _trendingItems.length,
            itemBuilder: (context, index) {
              final item = _trendingItems[index];
              return _buildTrendingItem(item, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingItem(Map<String, dynamic> item, int index) {
    final title = item['title'] ?? item['name'] ?? '';
    final isMovie = item['title'] != null;
    final poster = TmdbService.getPosterUrl(item['poster_path'], size: 'w92');

    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 25,
            child: Text(
              '${index + 1}',
              style: GoogleFonts.outfit(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 50,
            height: 75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              image: poster.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(poster),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: poster.isEmpty ? Colors.grey[800] : null,
            ),
            child: poster.isEmpty
                ? const Icon(Icons.movie, color: Colors.grey, size: 24)
                : null,
          ),
        ],
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Icon(isMovie ? Icons.movie : Icons.tv, color: Colors.grey, size: 14),
          const SizedBox(width: 4),
          Text(
            isMovie ? 'Filme' : 'Série',
            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
      trailing: const Icon(
        Icons.play_circle_outline,
        color: AppColors.primaryRed,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailsScreen(item: item, isMovie: isMovie),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryRed),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text(
              'Nenhum resultado encontrado',
              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente buscar por outro termo',
              style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.55,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return _buildSearchResultCard(item);
      },
    );
  }

  Widget _buildSearchResultCard(Map<String, dynamic> item) {
    final title = item['title'] ?? item['name'] ?? '';
    final poster = TmdbService.getPosterUrl(item['poster_path']);
    final isMovie = item['media_type'] == 'movie';
    final rating = (item['vote_average'] ?? 0).toDouble();

    final normalized = M3uService.normalizeTitle(title);
    final isAvailable = _availableTitles.any((it) {
      if (it.contains(normalized) || normalized.contains(it)) return true;
      final tmdbWords = normalized
          .split(' ')
          .where((w) => w.length > 3)
          .toList();
      if (tmdbWords.length >= 2) {
        return tmdbWords.every((word) => it.contains(word));
      }
      return false;
    });
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailsScreen(item: item, isMovie: isMovie),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  if (poster.isEmpty)
                    const Center(
                      child: Icon(Icons.movie, color: Colors.grey, size: 40),
                    ),

                  // Availability Badge
                  Positioned(
                    bottom: 6,
                    left: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? Colors.green.withOpacity(0.85)
                            : Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isAvailable
                              ? Colors.green
                              : Colors.grey.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isAvailable ? Icons.play_arrow : Icons.lock_outline,
                            color: Colors.white,
                            size: 8,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isAvailable ? 'ASSISTIR' : 'INDISPONÍVEL',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Rating badge
                  if (rating > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
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
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Type badge
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isMovie ? 'Filme' : 'Série',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 7.5) return Colors.green;
    if (rating >= 6.0) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
