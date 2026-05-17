import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import '../models/media_item.dart';

enum SignalStatus {
  /// URL resolved (static profile URL or acquired signal).
  ok,
  /// `acquire_signal` returned `error: 'lotado'` — all stock signals are in use.
  stockExhausted,
  /// User has no signal and stock state could not be confirmed (RPC error etc).
  unavailable,
  /// No authenticated user.
  notAuthenticated,
}

class SignalResult {
  final SignalStatus status;
  final String? url;
  const SignalResult({required this.status, this.url});
}

class M3uService {
  final _supabase = Supabase.instance.client;
  static const String _cacheFileName = 'm3u_cache_v21.json';
  static Timer? _heartbeatTimer;
  static const Duration _cacheTtl = Duration(hours: 24);
  static const int _maxCacheSlots = 5;

  /// Hash a URL so it is never stored in plaintext
  static String _hashUrl(String url) {
    final bytes = utf8.encode(url);
    return sha256.convert(bytes).toString();
  }

  /// Obfuscate a stream URL for cache storage
  static String _obfuscateUrl(String url) {
    return base64Encode(utf8.encode(url));
  }

  /// Deobfuscate a stream URL from cache
  static String _deobfuscateUrl(String encoded) {
    try {
      return utf8.decode(base64Decode(encoded));
    } catch (_) {
      return encoded; // Fallback for old cache format
    }
  }

  static String normalizeTitle(String title) {
    if (title.isEmpty) return '';
    String text = title.toLowerCase();

    // 1. Remove accents (Fix for matching Portuguese titles)
    text = text
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c')
        // Fix common encoding issues
        .replaceAll('Ã¡', 'a')
        .replaceAll('Ã¢', 'a')
        .replaceAll('Ã£', 'a')
        .replaceAll('Ã©', 'e')
        .replaceAll('Ãª', 'e')
        .replaceAll('Ã­', 'i')
        .replaceAll('Ã³', 'o')
        .replaceAll('Ã´', 'o')
        .replaceAll('Ãµ', 'o')
        .replaceAll('Ãº', 'u')
        .replaceAll('Ã§', 'c');

    text = text
        .replaceAll(RegExp(r'[\(\[\{].*?[\)\]\}]'), ' ')
        .replaceAll(
          RegExp(r'\b(4k|uhd|fullhd|fhd|hd|sd|720p|1080p|2160p)\b'),
          ' ',
        )
        .replaceAll(RegExp(r'\b(dublado|legendado|dub|leg|multi|dual)\b'), ' ')
        .replaceAll(
          RegExp(r'\b[st]\d{1,2}\s*[-.]?\s*e\d{1,2}\b', caseSensitive: false),
          ' ',
        );
    return text
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<io.File?> _getCacheFile() async {
    if (kIsWeb) return null;
    final directory = await getApplicationDocumentsDirectory();
    return io.File('${directory.path}/$_cacheFileName');
  }

  Future<Map<String, dynamic>> _readCacheMap() async {
    try {
      final file = await _getCacheFile();
      if (file == null || !await file.exists()) return {};
      final content = await file.readAsString();
      if (content.isEmpty) return {};
      final data = json.decode(content);
      if (data is! Map || data['version'] != 21) return {};
      return Map<String, dynamic>.from(data['slots'] ?? {});
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeCacheMap(Map<String, dynamic> slots) async {
    try {
      final file = await _getCacheFile();
      if (file == null) return;
      await file.writeAsString(json.encode({'version': 21, 'slots': slots}));
    } catch (_) {}
  }

  List<MediaItem> _decodeItems(dynamic rawList) {
    if (rawList == null) return [];
    return (rawList as List).map((j) {
      final map = Map<String, dynamic>.from(j as Map);
      if (map['url'] != null && !map['url'].toString().startsWith('http')) {
        map['url'] = _deobfuscateUrl(map['url'].toString());
      }
      return MediaItem.fromJson(map);
    }).toList();
  }

  Future<Map<String, dynamic>?> _getCacheEntry(String url) async {
    final slots = await _readCacheMap();
    final entry = slots[_hashUrl(url)];
    return entry is Map ? Map<String, dynamic>.from(entry) : null;
  }

  /// Cache the parsed items locally — multi-slot, max [_maxCacheSlots] URLs.
  Future<void> cacheM3uItems(String url, List<MediaItem> items) async {
    if (kIsWeb) return;
    try {
      final slots = await _readCacheMap();
      final key = _hashUrl(url);

      // Evict oldest slot when at limit (excluding current key)
      if (!slots.containsKey(key) && slots.length >= _maxCacheSlots) {
        String? oldestKey;
        DateTime? oldestTs;
        for (final e in slots.entries) {
          final ts = e.value is Map
              ? DateTime.tryParse((e.value as Map)['timestamp'] ?? '')
              : null;
          if (ts != null && (oldestTs == null || ts.isBefore(oldestTs))) {
            oldestTs = ts;
            oldestKey = e.key;
          }
        }
        if (oldestKey != null) slots.remove(oldestKey);
      }

      final jsonList = items.map((i) {
        final map = i.toJson();
        map['url'] = _obfuscateUrl(map['url'] ?? '');
        return map;
      }).toList();

      slots[key] = {
        'items': jsonList,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _writeCacheMap(slots);
    } catch (_) {
      debugPrint('M3uService: Cache write error');
    }
  }

  /// Returns cached items only if cache is fresh (within [_cacheTtl]).
  /// Returns null if missing or expired.
  Future<List<MediaItem>?> getCachedM3uItems(String url) async {
    if (kIsWeb) return null;
    final entry = await _getCacheEntry(url);
    if (entry == null) return null;
    final ts = DateTime.tryParse(entry['timestamp'] ?? '');
    if (ts == null || DateTime.now().difference(ts) > _cacheTtl) return null;
    return _decodeItems(entry['items']);
  }

  /// Returns cached items ignoring TTL (stale-while-revalidate).
  /// Returns null only when no cache exists at all.
  Future<List<MediaItem>?> getStaleCachedItems(String url) async {
    if (kIsWeb) return null;
    final entry = await _getCacheEntry(url);
    if (entry == null) return null;
    return _decodeItems(entry['items']);
  }

  /// True if a cache entry exists AND is younger than [_cacheTtl].
  Future<bool> isCacheFresh(String url) async {
    if (kIsWeb) return false;
    final entry = await _getCacheEntry(url);
    if (entry == null) return false;
    final ts = DateTime.tryParse(entry['timestamp'] ?? '');
    if (ts == null) return false;
    return DateTime.now().difference(ts) <= _cacheTtl;
  }

  Future<MediaItem?> searchMatch(String title) async {
    try {
      // Use the centralized URL logic to ensure we search the same M3U that is cached/loaded
      final url = await getUserM3uUrl();
      if (url == null) return null;

      final items = await getStaleCachedItems(url);
      if (items == null || items.isEmpty) return null;

      final searchTitle = normalizeTitle(title);
      if (searchTitle.isEmpty) return null;

      MediaItem? bestMatch;
      int bestScore = 0;

      for (var item in items) {
        final itemTitle = normalizeTitle(item.title);
        int score = 0;

        if (itemTitle == searchTitle) {
          score = 100;
        } else if (itemTitle.contains(searchTitle) ||
            searchTitle.contains(itemTitle)) {
          score = (itemTitle.length > searchTitle.length)
              ? (searchTitle.length / itemTitle.length * 90).round()
              : (itemTitle.length / searchTitle.length * 85).round();
        }

        if (score > bestScore) {
          bestScore = score;
          bestMatch = item;
          if (score == 100) break;
        }
      }

      return bestScore >= 50 ? bestMatch : null;
    } catch (e) {
      debugPrint('M3uService: Search match error');
      return null;
    }
  }

  Future<List<String>> getCachedAvailableTitles() async {
    try {
      // Use centralized URL retrieval to handle both Static and Dynamic URLs
      final url = await getUserM3uUrl();
      if (url == null) return [];

      final items = await getStaleCachedItems(url);
      if (items == null) return [];

      final Set<String> uniqueTitles = {};
      for (var item in items) {
        final normalized = normalizeTitle(item.title);
        if (normalized.length > 2) {
          uniqueTitles.add(normalized);
        }
      }
      return uniqueTitles.toList();
    } catch (e) {
      debugPrint('M3uService: Available titles error');
      return [];
    }
  }

  /// Get the M3U URL for the current user.
  /// Thin wrapper over [acquireSignal] for callers that only need the URL.
  Future<String?> getUserM3uUrl() async {
    final result = await acquireSignal();
    return result.url;
  }

  /// Returns the persistent session UUID for code-access users.
  /// Generated once and stored in SharedPreferences.
  static Future<String> _codeSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('code_session_id');
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString('code_session_id', id);
    }
    return id;
  }

  /// Acquire a signal from the pool using [userId].
  /// Shared by both authenticated users and code-access users.
  Future<SignalResult> _acquireFromPool(String userId) async {
    Map<String, dynamic>? rpcResponse;
    try {
      final dynamic raw = await _supabase
          .schema('startflix')
          .rpc('acquire_signal', params: {'p_user_id': userId});
      if (raw is Map) rpcResponse = Map<String, dynamic>.from(raw);
    } catch (rpcError) {
      debugPrint('M3uService: acquire_signal RPC failed: $rpcError');
    }

    if (rpcResponse != null && rpcResponse['success'] == true) {
      final url = _buildM3uUrl(
        rpcResponse['dns'] as String?,
        rpcResponse['username'] as String?,
        rpcResponse['password'] as String?,
      );
      if (url != null) return SignalResult(status: SignalStatus.ok, url: url);
    }

    // Direct query fallback (RPC network error / cache miss)
    try {
      final account = await _supabase
          .schema('startflix')
          .from('media_accounts')
          .select('dns, username, password')
          .eq('user_id', userId)
          .maybeSingle();
      if (account != null) {
        final url = _buildM3uUrl(
          account['dns'] as String?,
          account['username'] as String?,
          account['password'] as String?,
        );
        if (url != null) {
          debugPrint('M3uService: signal found via direct query');
          return SignalResult(status: SignalStatus.ok, url: url);
        }
      }
    } catch (queryError) {
      debugPrint('M3uService: direct media_accounts query failed: $queryError');
    }

    if (rpcResponse != null && rpcResponse['error'] == 'lotado') {
      return const SignalResult(status: SignalStatus.stockExhausted);
    }
    return const SignalResult(status: SignalStatus.unavailable);
  }

  /// Resolve the user's signal. Returns a [SignalResult] so callers can show
  /// a meaningful message when no signal could be acquired.
  ///
  /// Works for both authenticated users and code-access users (which use a
  /// persistent device UUID stored in SharedPreferences).
  Future<SignalResult> acquireSignal() async {
    try {
      final user = _supabase.auth.currentUser;

      // ── Code-access path (no Supabase auth session) ──────────────────────
      if (user == null) {
        final prefs = await SharedPreferences.getInstance();
        final isCodeAccess = prefs.getBool('is_code_access') ?? false;
        if (!isCodeAccess) {
          return const SignalResult(status: SignalStatus.notAuthenticated);
        }
        final sessionId = await _codeSessionId();
        return _acquireFromPool(sessionId);
      }

      // ── Authenticated user path ───────────────────────────────────────────
      // 1. Static URL in profile takes priority.
      final profile = await _supabase
          .schema('startflix')
          .from('profiles')
          .select('m3u_url')
          .eq('id', user.id)
          .maybeSingle();

      final staticUrl = profile?['m3u_url'] as String?;
      if (staticUrl != null && staticUrl.trim().isNotEmpty) {
        return SignalResult(status: SignalStatus.ok, url: staticUrl.trim());
      }

      // 2. Acquire from shared pool.
      return _acquireFromPool(user.id);
    } catch (e) {
      debugPrint('M3uService: URL retrieval error: $e');
      return const SignalResult(status: SignalStatus.unavailable);
    }
  }

  static String? _buildM3uUrl(String? dns, String? username, String? password) {
    if (dns == null || username == null || password == null) return null;
    String host = dns.trim();
    if (!host.startsWith('http')) host = 'http://$host';
    if (host.contains('get.php')) return host;
    if (host.endsWith('/')) host = host.substring(0, host.length - 1);
    return '$host/get.php?username=$username&password=$password&type=m3u_plus&output=ts';
  }

  /// Release the signal back to the pool.
  /// Works for both authenticated users and code-access users.
  Future<void> releaseSignal() async {
    try {
      final user = _supabase.auth.currentUser;
      String? userId = user?.id;

      if (userId == null) {
        final prefs = await SharedPreferences.getInstance();
        final isCodeAccess = prefs.getBool('is_code_access') ?? false;
        if (!isCodeAccess) return;
        userId = prefs.getString('code_session_id');
        if (userId == null) return;
      }

      await _supabase
          .schema('startflix')
          .rpc('release_signal', params: {'p_user_id': userId});
    } catch (e) {
      debugPrint('M3uService: Signal release error');
    }
  }

  /// Starts a periodic heartbeat (every 2 min) so the admin panel can detect
  /// active users and auto-release signals from users who left the app.
  Future<void> startHeartbeat() async {
    _heartbeatTimer?.cancel();
    final user = _supabase.auth.currentUser;
    String? userId = user?.id;
    if (userId == null) {
      final prefs = await SharedPreferences.getInstance();
      final isCodeAccess = prefs.getBool('is_code_access') ?? false;
      if (!isCodeAccess) return;
      userId = prefs.getString('code_session_id');
      if (userId == null) return;
    }
    final capturedUserId = userId;
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 2), (_) async {
      try {
        await _supabase
            .schema('startflix')
            .rpc('send_heartbeat', params: {'p_user_id': capturedUserId});
      } catch (_) {}
    });
  }

  static void stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Checks the server-side m3u_cache table for a pre-fetched copy of [url].
  /// Only used for public/non-credential URLs (default lists).
  Future<String?> _getServerCachedContent(String url) async {
    if (url.contains('username=') || url.contains('password=')) return null;
    try {
      final row = await _supabase
          .schema('startflix')
          .from('m3u_cache')
          .select('m3u_content, cached_at')
          .eq('source_url', url)
          .eq('status', 'ready')
          .maybeSingle();
      if (row == null) return null;
      final cachedAt = DateTime.tryParse(row['cached_at'] ?? '');
      final content = row['m3u_content'] as String?;
      if (cachedAt == null || content == null || content.isEmpty) return null;
      if (DateTime.now().difference(cachedAt) > _cacheTtl) return null;
      return content;
    } catch (_) {
      return null;
    }
  }

  Future<List<MediaItem>> parseM3uUrl(String url) async {
    final trimmedUrl = url.trim();

    // For public default lists: try server-side cache first (faster than IPTV provider)
    final serverContent = await _getServerCachedContent(trimmedUrl);
    if (serverContent != null) {
      try {
        return await compute(
          _parseM3uContentStatic,
          Uint8List.fromList(utf8.encode(serverContent)),
        );
      } catch (_) {
        // fall through to direct fetch
      }
    }

    try {
      final response = await http.get(
        Uri.parse(trimmedUrl),
        headers: {'User-Agent': 'IPTVSmartersPlayer'},
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        if (response.bodyBytes.isEmpty) {
          throw Exception('A lista retornada está vazia.');
        }

        // Use compute to parse in a background isolate
        return await compute(_parseM3uContentStatic, response.bodyBytes);
      } else {
        throw Exception(
          'Falha ao carregar lista. Servidor retornou Erro HTTP ${response.statusCode}. Contate o administrador.',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
        'Erro ao conectar ao servidor da lista. Tente novamente.',
      );
    }
  }
}

// --- Static functions for compute ---

Future<List<MediaItem>> _parseM3uContentStatic(Uint8List bytes) async {
  final List<MediaItem> items = [];

  // Custom simple parser to avoid creating the huge full-content String
  // We iterate through bytes  // Determine encoding
  String decoded;
  try {
    decoded = utf8.decode(bytes);
  } catch (e) {
    try {
      decoded = latin1.decode(bytes);
    } catch (_) {
      decoded = String.fromCharCodes(bytes); // Fallback
    }
  }

  final lines = LineSplitter.split(decoded).toList();

  String? pendingRawExtinf;

  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;

    if (trimmed.startsWith('#EXTINF')) {
      pendingRawExtinf = trimmed;
    } else if (pendingRawExtinf != null && !trimmed.startsWith('#')) {
      // URL line
      items.add(_fastParseExtinfAndUrl(pendingRawExtinf, trimmed));
      pendingRawExtinf = null;
    }
  }

  return items;
}

MediaItem _fastParseExtinfAndUrl(String extinfLine, String url) {
  // 1. Extract Raw Name (everything after the formatting comma)
  // #EXTINF:-1 tvg-id=""..., Name of Channel
  String rawName = "Sem Nome";
  final commaIndex = extinfLine.lastIndexOf(',');
  if (commaIndex != -1 && commaIndex < extinfLine.length - 1) {
    rawName = extinfLine.substring(commaIndex + 1).trim();
  }

  // 2. Extract group-title
  // Optimized: search for 'group-title="'
  String? group = _getAttrValue(extinfLine, 'group-title');
  group ??= _getAttrValue(extinfLine, 'tvg-group');
  group ??= "Geral";

  // 3. Extract logo
  // Try common attributes
  String? logo = _getAttrValue(extinfLine, 'tvg-logo');
  logo ??= _getAttrValue(extinfLine, 'logo');
  logo ??= _getAttrValue(extinfLine, 'icon');
  logo ??= _getAttrValue(extinfLine, 'thumb');

  // 4. Heuristics for Series and Movies
  final isSeriesGuess = _fastIsSeries(group, rawName, url);
  final isMovieGuess = _fastIsMovie(group, rawName, url, isSeriesGuess);

  // 5. Parse Season/Episode from Name
  // e.g. "S01 E05", "1x05"
  int? season;
  int? episode;
  String cleanedName = rawName;

  if (isSeriesGuess) {
    final se = _extractSeasonEpisode(rawName);
    if (se != null) {
      season = se['s'];
      episode = se['e'];
      // Remove the SxxExx part from name for cleaner display
      if (se['match'] != null) {
        cleanedName = rawName.replaceAll(se['match']!, '').trim();
        // Cleanup trailing separators like " - "
        if (cleanedName.endsWith('-')) {
          cleanedName = cleanedName.substring(0, cleanedName.length - 1).trim();
        }
      }
    }
  }

  // 6. Extract xui-id, tvg-id, tvg-name
  String? xuiId = _getAttrValue(extinfLine, 'xui-id');
  if (xuiId?.isEmpty ?? false) xuiId = null;

  String? tvgId = _getAttrValue(extinfLine, 'tvg-id');
  if (tvgId?.isEmpty ?? false) tvgId = null;

  String? tvgName = _getAttrValue(extinfLine, 'tvg-name');
  if (tvgName?.isEmpty ?? false) tvgName = null;

  return MediaItem(
    title: cleanedName, // Name displayed
    url: url,
    logoUrl: logo,
    group: group,
    isSeries: isSeriesGuess,
    isMovie: isMovieGuess,
    season: season,
    episode: episode,
    xuiId: xuiId,
    tvgId: tvgId,
    tvgName: tvgName,
  );
}

// Optimized attribute extractor using indexOf instead of Regex
String? _getAttrValue(String line, String attrName) {
  final key = '$attrName="';
  int start = line.indexOf(key);
  if (start == -1) return null;

  start += key.length;
  final end = line.indexOf('"', start);
  if (end == -1) return null; // malformed?

  return line.substring(start, end);
}

// -------------------------------------------------------------------------
// REFINED CLASSIFIERS
// -------------------------------------------------------------------------

// Pre-compiled RegExp patterns for performance (avoids re-creating per item)
final _reSxxExx = RegExp(r'\bs\d{1,2}\s*[-.:]?\s*e\d{1,3}\b');
final _reTxxEPxx = RegExp(r'\bt\d{1,2}\s*ep\d{1,3}\b');
final _reNxN = RegExp(r'\b\d{1,2}x\d{1,3}\b');
final _reCapitulo = RegExp(r'\bcap[ií]tulo\s*\d+\b');
final _reSxx = RegExp(r'\bs\d{1,2}\b');
final _reYear = RegExp(r'\(\d{4}\)');

/// Helper to normalize strings before classification checks
String _classifyClean(String s) {
  return s
      .toLowerCase()
      .replaceAll('Ã¡', 'a')
      .replaceAll('Ã¢', 'a')
      .replaceAll('Ã£', 'a')
      .replaceAll('Ã©', 'e')
      .replaceAll('Ãª', 'e')
      .replaceAll('Ã­', 'i')
      .replaceAll('Ã³', 'o')
      .replaceAll('Ã´', 'o')
      .replaceAll('Ãµ', 'o')
      .replaceAll('Ãº', 'u')
      .replaceAll('Ã§', 'c')
      .replaceAll('ã¡', 'a') // alternate broken forms
      .replaceAll('ã£', 'a')
      .replaceAll('ã©', 'e')
      .replaceAll('ã§', 'c')
      .trim();
}

/// Helper to identify VOD URLs (Movies/Series) for this server
bool _isVodUrl(String u) {
  // If URL contains common file extensions at the end (before fragments if any)
  // This server uses #.mp4 as a strong indicator
  if (u.contains('#.mp4') || u.contains('#.mkv') || u.contains('#.avi')) {
    return true;
  }

  if (u.endsWith('.mp4') ||
      u.endsWith('.mkv') ||
      u.endsWith('.avi') ||
      u.endsWith('.webm') ||
      u.endsWith('.m4v')) {
    return true;
  }

  return false;
}

/// 1. Check for Series
bool _fastIsSeries(String group, String name, String url) {
  final u = url.toLowerCase();

  // 1. URL Check (Strongest Indicator)
  if (u.contains('/series/') ||
      u.contains('/serie/') ||
      u.contains('type=series')) {
    return true;
  }

  final n = name.toLowerCase();

  // 2. Name Regex (Strong Indicator)
  if (n.contains(_reSxxExx) ||
      n.contains(_reTxxEPxx) ||
      n.contains(_reNxN) ||
      n.contains(_reCapitulo)) {
    return true;
  }

  final g = _classifyClean(group);

  // 3. Group Title indicates series (Medium Indicator)
  if (g.contains('serie') ||
      g.contains('season') ||
      g.contains('temporada') ||
      g.contains('episodio') ||
      g.contains('novelas') ||
      g.contains('animes') ||
      g.contains('doramas') ||
      g.contains('desenhos') ||
      g.contains('netflix') ||
      g.contains('globoplay') ||
      g.contains('amazon prime') ||
      g.contains('disney+') ||
      g.contains('hbo max')) {
    // Safety check: Avoid Live 24h channels in mixed groups
    // If it's NOT a VOD URL, be skeptical of series groups
    final isVod = _isVodUrl(u);
    if (!isVod &&
        (g.contains('24h') ||
            g.contains('canais') ||
            g.contains('ao vivo') ||
            g.contains('filmes'))) {
      if (n.contains(_reSxx)) return true;
      return false;
    }

    return true;
  }

  return false;
}

/// 2. Check for Movies
bool _fastIsMovie(String group, String name, String url, bool isSeries) {
  if (isSeries) return false;

  final u = url.toLowerCase();

  // 1. URL Check (Super Strong)
  if (u.contains('/movie/') ||
      u.contains('type=movie') ||
      u.contains('type=vod')) {
    return true;
  }

  // 2. The Golden Rule for this server: #.mp4 etc
  if (_isVodUrl(u)) {
    // If it's a VOD URL and not a Series, it's a Movie.
    // Exception: Explicit live indicators
    if (u.contains('/live/') || u.contains('type=live')) return false;

    return true;
  }

  final g = _classifyClean(group);
  final n = name.toLowerCase();

  // 3. Negative check for known Broadcasters (Channels)
  if (_isBroadcasterName(n)) {
    if (!n.contains(_reYear)) {
      return false; // Safely assume Channel
    }
  }

  // 4. Group Name Indicators
  if (g.contains('filmes') ||
      g.contains('movies') ||
      g.contains('vod') ||
      g.contains('ondemand') ||
      g.contains('box office') ||
      g.contains('cine') ||
      g.contains('cinema') ||
      g.contains('4k') ||
      g.contains('lancamento')) {
    // If it has a movie path, it's a movie.
    if (u.contains('/movie/')) return true;

    // If it's NOT a VOD URL and is a generic "Filmes" group name/channel
    if (!_isVodUrl(u)) {
      // Only count as movie if name has year and isn't a known broadcaster
      if (n.contains(_reYear) && !_isBroadcasterName(n)) return true;
      if (n.contains('dublado') ||
          n.contains('legendado') ||
          n.contains('dual')) {
        return true;
      }

      return false; // Treat as Channel
    }
    return true;
  }

  // 5. Genre Groups
  if (g.contains('acao') ||
      g.contains('comedia') ||
      g.contains('terror') ||
      g.contains('suspense') ||
      g.contains('drama') ||
      g.contains('romance') ||
      g.contains('infantil') ||
      g.contains('adulto') ||
      g.contains('documentario') ||
      g.contains('faroeste') ||
      g.contains('guerra') ||
      g.contains('ficcao')) {
    // For this server, genres without #.mp4 are almost always Live Channels
    if (!_isVodUrl(u)) {
      if (n.contains(_reYear)) return true;
      return false; // Assume genre-themed channel
    }

    return true;
  }

  // 6. Name Indicators
  if (n.contains(_reYear)) return true;

  return false;
}

/// 3. Check for Channels (Helper)
// _fastIsChannelGroup removed as it is no longer used.

// _fastIsChannelName removed as it is no longer used.
// We rely on Group Names and Broadcaster Names.

bool _isBroadcasterName(String nameLower) {
  return nameLower.contains('globo') ||
      nameLower.contains('sbt') ||
      nameLower.contains('record') ||
      nameLower.contains('band') || // be careful with "Banda..."
      nameLower.contains('espn') ||
      nameLower.contains('hbo') ||
      nameLower.contains('telecine') ||
      nameLower.contains('premiere') ||
      nameLower.contains('sportv') ||
      nameLower.contains('fox') ||
      nameLower.contains('discovery') ||
      nameLower.contains('natgeo') ||
      nameLower.contains('history') ||
      nameLower.contains('animal planet') ||
      nameLower.contains('nick') ||
      nameLower.contains('disney') ||
      nameLower.contains('cartoon') ||
      nameLower.contains('tnt') ||
      nameLower.contains('axn') ||
      nameLower.contains('sony') ||
      nameLower.contains('warner') ||
      nameLower.contains('space') ||
      nameLower.contains('universal') ||
      nameLower.contains('megapix') ||
      nameLower.contains('cinemax') ||
      nameLower.contains('paramount') ||
      nameLower.contains('fx') ||
      nameLower.contains('amc') ||
      nameLower.contains('tvcine') ||
      nameLower.contains('cnn') ||
      nameLower.contains('combate');
}

// Pre-compiled extraction patterns
final _reExtractSxE = RegExp(
  r'\bS(\d{1,2})\s*[-.:]?\s*E(\d{1,3})\b',
  caseSensitive: false,
);
final _reExtractTxE = RegExp(
  r'\bT(\d{1,2})\s*EP?(\d{1,3})\b',
  caseSensitive: false,
);
final _reExtractXxY = RegExp(r'\b(\d{1,2})x(\d{1,3})\b');
final _reExtractEpX = RegExp(
  r'\bEp(isodi[oa])?\s*(\d{1,3})\b',
  caseSensitive: false,
);

Map<String, dynamic>? _extractSeasonEpisode(String name) {
  // SxxExx
  var m = _reExtractSxE.firstMatch(name);
  if (m != null) {
    return {
      's': int.tryParse(m.group(1)!),
      'e': int.tryParse(m.group(2)!),
      'match': m.group(0),
    };
  }

  // TxxExx
  m = _reExtractTxE.firstMatch(name);
  if (m != null) {
    return {
      's': int.tryParse(m.group(1)!),
      'e': int.tryParse(m.group(2)!),
      'match': m.group(0),
    };
  }

  // 1x01
  m = _reExtractXxY.firstMatch(name);
  if (m != null) {
    return {
      's': int.tryParse(m.group(1)!),
      'e': int.tryParse(m.group(2)!),
      'match': m.group(0),
    };
  }

  // EpXX
  m = _reExtractEpX.firstMatch(name);
  if (m != null) {
    // Assume season 1 if not found
    return {'s': 1, 'e': int.tryParse(m.group(2)!), 'match': m.group(0)};
  }

  return null;
}
