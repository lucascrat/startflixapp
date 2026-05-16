import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TmdbService {
  static const String _apiKey =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhMTAwZTc5Y2U0ZjliZGUxNGZlYTY3Y2NiZDAyODU1YiIsIm5iZiI6MTc0MTMwNzU4NC4zODQsInN1YiI6IjY3Y2EzZWMwOGYwZTU5ODYzYmFmYmNlZiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.5dbC_0x_QIATSvTEdM9M6WfWrSXWqoNn0Xh1ZYrmAYE';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';

  // Image sizes
  static String getPosterUrl(String? path, {String size = 'w500'}) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl/$size$path';
  }

  static String getBackdropUrl(String? path, {String size = 'original'}) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl/$size$path';
  }

  static Map<String, String> get _headers => {
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
  };

  // In-memory cache
  static final Map<String, dynamic> _cache = {};
  static const Duration _cacheDuration = Duration(hours: 12);
  static final Map<String, DateTime> _cacheTime = {};

  static Future<dynamic> _fetchWithCache(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final String cacheKey = 'tmdb_cache_$url';

    // 1. Check Memory Cache
    if (_cache.containsKey(cacheKey)) {
      final cacheAge = DateTime.now().difference(_cacheTime[cacheKey]!);
      if (cacheAge < _cacheDuration) {
        return _cache[cacheKey]; // Fast return
      }
    }

    // 2. Check Disk Cache
    final String? diskCache = prefs.getString(cacheKey);
    final String? diskCacheTimeString = prefs.getString('${cacheKey}_time');

    if (diskCache != null && diskCacheTimeString != null) {
      final diskCacheTime = DateTime.parse(diskCacheTimeString);
      if (DateTime.now().difference(diskCacheTime) < _cacheDuration) {
        final decoded = jsonDecode(diskCache);
        // Load into memory
        _cache[cacheKey] = decoded;
        _cacheTime[cacheKey] = diskCacheTime;
        return decoded;
      }
    }

    // 3. Fetch from Network
    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save to memory
        _cache[cacheKey] = data;
        _cacheTime[cacheKey] = DateTime.now();

        // Save to Disk
        prefs.setString(cacheKey, response.body);
        prefs.setString('${cacheKey}_time', DateTime.now().toIso8601String());

        return data;
      }
    } catch (e) {
      print('Error fetching from TMDB network: $e');
    }

    // Fallback exactly to last known disk cache if network fails, regardless of expiration
    if (diskCache != null) {
      return jsonDecode(diskCache);
    }

    return null;
  }

  // === MOVIES ===

  /// Get trending movies (day/week)
  Future<List<Map<String, dynamic>>> getTrendingMovies({
    String timeWindow = 'day',
  }) async {
    final url = '$_baseUrl/trending/movie/$timeWindow?language=pt-BR';
    final data = await _fetchWithCache(url);
    if (data != null && data['results'] != null) {
      return List<Map<String, dynamic>>.from(data['results']);
    }
    return [];
  }

  /// Get popular movies
  Future<List<Map<String, dynamic>>> getPopularMovies() async {
    final url = '$_baseUrl/movie/popular?language=pt-BR&region=BR';
    final data = await _fetchWithCache(url);
    if (data != null && data['results'] != null) {
      return List<Map<String, dynamic>>.from(data['results']);
    }
    return [];
  }

  /// Get top rated movies
  Future<List<Map<String, dynamic>>> getTopRatedMovies() async {
    final url = '$_baseUrl/movie/top_rated?language=pt-BR&region=BR';
    final data = await _fetchWithCache(url);
    if (data != null && data['results'] != null) {
      return List<Map<String, dynamic>>.from(data['results']);
    }
    return [];
  }

  /// Get now playing movies
  Future<List<Map<String, dynamic>>> getNowPlayingMovies() async {
    final url = '$_baseUrl/movie/now_playing?language=pt-BR&region=BR';
    final data = await _fetchWithCache(url);
    if (data != null && data['results'] != null) {
      return List<Map<String, dynamic>>.from(data['results']);
    }
    return [];
  }

  /// Get upcoming movies
  Future<List<Map<String, dynamic>>> getUpcomingMovies() async {
    final url = '$_baseUrl/movie/upcoming?language=pt-BR&region=BR';
    final data = await _fetchWithCache(url);
    if (data != null && data['results'] != null) {
      return List<Map<String, dynamic>>.from(data['results']);
    }
    return [];
  }

  // === TV SHOWS ===

  /// Get trending TV shows
  Future<List<Map<String, dynamic>>> getTrendingTvShows({
    String timeWindow = 'day',
  }) async {
    final url = '$_baseUrl/trending/tv/$timeWindow?language=pt-BR';
    final data = await _fetchWithCache(url);
    if (data != null && data['results'] != null) {
      return List<Map<String, dynamic>>.from(data['results']);
    }
    return [];
  }

  /// Get popular TV shows
  Future<List<Map<String, dynamic>>> getPopularTvShows() async {
    final url = '$_baseUrl/tv/popular?language=pt-BR';
    final data = await _fetchWithCache(url);
    if (data != null && data['results'] != null) {
      return List<Map<String, dynamic>>.from(data['results']);
    }
    return [];
  }

  /// Get top rated TV shows
  Future<List<Map<String, dynamic>>> getTopRatedTvShows() async {
    final url = '$_baseUrl/tv/top_rated?language=pt-BR';
    final data = await _fetchWithCache(url);
    if (data != null && data['results'] != null) {
      return List<Map<String, dynamic>>.from(data['results']);
    }
    return [];
  }

  /// Get TV shows airing today
  Future<List<Map<String, dynamic>>> getAiringTodayTvShows() async {
    final url = '$_baseUrl/tv/airing_today?language=pt-BR';
    final data = await _fetchWithCache(url);
    if (data != null && data['results'] != null) {
      return List<Map<String, dynamic>>.from(data['results']);
    }
    return [];
  }

  // === SEARCH ===

  /// Search movies and TV shows
  Future<List<Map<String, dynamic>>> searchMulti(String query) async {
    if (query.isEmpty) return [];
    final url =
        '$_baseUrl/search/multi?query=${Uri.encodeComponent(query)}&language=pt-BR';
    final data = await _fetchWithCache(url);
    if (data != null && data['results'] != null) {
      return List<Map<String, dynamic>>.from(data['results']);
    }
    return [];
  }

  // === DETAILS ===

  /// Get movie details
  Future<Map<String, dynamic>?> getMovieDetails(int movieId) async {
    final url =
        '$_baseUrl/movie/$movieId?language=pt-BR&append_to_response=videos,credits,similar';
    final data = await _fetchWithCache(url);
    return data;
  }

  /// Get TV show details
  Future<Map<String, dynamic>?> getTvShowDetails(int tvId) async {
    final url =
        '$_baseUrl/tv/$tvId?language=pt-BR&append_to_response=videos,credits,similar';
    final data = await _fetchWithCache(url);
    return data;
  }

  // === GENRES ===

  /// Get movie genres
  Future<List<Map<String, dynamic>>> getMovieGenres() async {
    final url = '$_baseUrl/genre/movie/list?language=pt-BR';
    final data = await _fetchWithCache(url);
    if (data != null && data['genres'] != null) {
      return List<Map<String, dynamic>>.from(data['genres']);
    }
    return [];
  }

  /// Get movies by genre
  Future<List<Map<String, dynamic>>> getMoviesByGenre(int genreId) async {
    final url =
        '$_baseUrl/discover/movie?with_genres=$genreId&language=pt-BR&sort_by=popularity.desc';
    final data = await _fetchWithCache(url);
    if (data != null && data['results'] != null) {
      return List<Map<String, dynamic>>.from(data['results']);
    }
    return [];
  }
}
