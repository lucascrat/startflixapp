import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';
import '../services/tmdb_service.dart';
import 'movie_details_screen.dart';

// Schema name for Supabase queries
const String _supabaseSchema = 'startflix';

// Helper to get table with schema
SupabaseQueryBuilder _fromTable(String table) =>
    Supabase.instance.client.schema(_supabaseSchema).from(table);

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  List<Map<String, dynamic>> _watchlist = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await _fromTable(
        'user_watchlist',
      ).select().eq('user_id', userId).order('added_at', ascending: false);

      if (mounted) {
        setState(() {
          _watchlist = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading watchlist: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removeFromWatchlist(String id) async {
    try {
      await _fromTable('user_watchlist').delete().eq('id', id);

      setState(() {
        _watchlist.removeWhere((item) => item['id'] == id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removido da sua lista'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Minha Lista',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_watchlist.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_watchlist.length} itens',
                    style: GoogleFonts.outfit(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
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
          : _watchlist.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadWatchlist,
              color: AppColors.primaryRed,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                ),
                itemCount: _watchlist.length,
                itemBuilder: (context, index) {
                  return _buildWatchlistItem(_watchlist[index]);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 80, color: Colors.grey[600]),
          const SizedBox(height: 20),
          Text(
            'Sua lista está vazia',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Adicione filmes e séries para assistir depois',
            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistItem(Map<String, dynamic> item) {
    final posterPath = item['poster_path'];
    final posterUrl = posterPath != null && posterPath.isNotEmpty
        ? TmdbService.getPosterUrl(posterPath)
        : '';
    final isMovie = item['media_type'] == 'movie';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailsScreen(
              item: {
                'id': item['tmdb_id'],
                'title': isMovie ? item['title'] : null,
                'name': !isMovie ? item['title'] : null,
                'poster_path': item['poster_path'],
                'backdrop_path': item['backdrop_path'],
                'overview': item['overview'],
                'vote_average': item['vote_average'],
                'release_date': isMovie ? item['release_date'] : null,
                'first_air_date': !isMovie ? item['release_date'] : null,
              },
              isMovie: isMovie,
            ),
          ),
        ).then((_) => _loadWatchlist());
      },
      onLongPress: () => _showRemoveDialog(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[850],
                    image: posterUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(posterUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: posterUrl.isEmpty
                      ? Center(
                          child: Icon(
                            isMovie ? Icons.movie : Icons.tv,
                            color: Colors.grey,
                            size: 40,
                          ),
                        )
                      : null,
                ),
                // Type badge
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isMovie ? Colors.purple : Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isMovie ? 'Filme' : 'Série',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Remove button
                Positioned(
                  top: 6,
                  left: 6,
                  child: GestureDetector(
                    onTap: () => _showRemoveDialog(item),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item['title'] ?? '',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Remover da lista?',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: Text(
          'Deseja remover "${item['title']}" da sua lista?',
          style: GoogleFonts.outfit(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.outfit(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeFromWatchlist(item['id']);
            },
            child: Text(
              'Remover',
              style: GoogleFonts.outfit(color: AppColors.primaryRed),
            ),
          ),
        ],
      ),
    );
  }
}
