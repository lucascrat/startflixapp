import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TmdbService {
  static const String _apiKey =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhMTAwZTc5Y2U0ZjliZGUxNGZlYTY3Y2NiZDAyODU1YiIsIm5iZiI6MTc0MTMwNzU4NC4zODQsInN1YiI6IjY3Y2EzZWMwOGYwZTU5ODYzYmFmYmNlZiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.5dbC_0x_QIATSvTEdM9M6WfWrSXWqoNn0Xh1ZYrmAYE';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';

  // Poster: w342 is enough for 130px cards. w500 wastes bandwidth.
  // Backdrop: w1280 is full-HD quality. 'original' can be 4–8 MB per image.
  static String getPosterUrl(String? path, {String size = 'w342'}) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl/$size$path';
  }

  static String getBackdropUrl(String? path, {String size = 'w1280'}) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl/$size$path';
  }

  static Map<String, String> get _headers => {
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
  };

  // In-memory cache — static so it persists across screen visits
  static final Map<String, dynamic> _cache = {};
  static const Duration _cacheDuration = Duration(hours: 12);
  static final Map<String, DateTime> _cacheTime = {};

  // SharedPreferences singleton — avoids repeated async getInstance() per fetch
  static SharedPreferences? _prefs;
  static Future<SharedPreferences> _getPrefs() async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Returns the raw cached payload for [url] synchronously (may be stale).
  /// Used by DiscoverScreen to show content instantly before the network refresh.
  static List<Map<String, dynamic>> getStaleResults(String url) {
    final raw = _cache['tmdb_cache_$url'];
    if (raw is Map && raw['results'] != null) {
      return List<Map<String, dynamic>>.from(raw['results'] as List);
    }
    return [];
  }

  static Future<dynamic> _fetchWithCache(String url) async {
    final String cacheKey = 'tmdb_cache_$url';

    // 1. Memory cache hit — no disk or network needed
    if (_cache.containsKey(cacheKey)) {
      final cacheAge = DateTime.now().difference(_cacheTime[cacheKey]!);
      if (cacheAge < _cacheDuration) {
        return _cache[cacheKey];
      }
    }

    // 2. Disk cache — reuse singleton prefs, no repeated getInstance()
    final prefs = await _getPrefs();
    final String? diskCache = prefs.getString(cacheKey);
    final String? diskCacheTimeStr = prefs.getString('${cacheKey}_time');

    if (diskCache != null && diskCacheTimeStr != null) {
      final diskCacheTime = DateTime.parse(diskCacheTimeStr);
      if (DateTime.now().difference(diskCacheTime) < _cacheDuration) {
        final decoded = jsonDecode(diskCache);
        _cache[cacheKey] = decoded;
        _cacheTime[cacheKey] = diskCacheTime;
        return decoded;
      }
    }

    // 3. Network fetch
    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cache[cacheKey] = data;
        _cacheTime[cacheKey] = DateTime.now();
        prefs.setString(cacheKey, response.body);
        prefs.setString('${cacheKey}_time', DateTime.now().toIso8601String());
        return data;
      }
    } catch (e) {
      debugPrint('TmdbService: network error: $e');
    }

    // 4. Fallback to stale disk cache on network failure
    if (diskCache != null) return jsonDecode(diskCache);
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
