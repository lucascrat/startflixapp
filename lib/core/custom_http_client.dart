import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';

// Intercepts Supabase auth calls (GoTrue) and routes them to our PostgREST RPCs.
// Our deployment has no GoTrue — only PostgREST. This client makes supabase_flutter
// think it has a real auth session by returning fake-but-parseable auth responses.
class CustomHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  static const String _userCacheKey = 'custom_auth_user';

  // Anon key used as the Bearer token so PostgREST accepts queries.
  static const String _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
      '.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzc4OTQ1MDQ4LCJleHAiOjIwOTQzMDUwNDh9'
      '.MP2-5TXurfkLspwA_3vft9g6nIY8sUHOBaqxPfkaKBg';

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final path = request.url.path;
    final query = request.url.query;

    // ── Auth interception ─────────────────────────────────────────────────────
    if (path == '/auth/v1/token') {
      if (query.contains('grant_type=password')) return _handleSignIn(request);
      if (query.contains('grant_type=refresh_token')) return _handleRefresh();
    }
    if (path == '/auth/v1/signup') return _handleSignUp(request);
    if (path == '/auth/v1/user') return _handleGetUser();
    if (path == '/auth/v1/logout') return _handleSignOut();
    if (path == '/auth/v1/settings') {
      return _jsonResponse(200, {
        'disable_signup': false,
        'mailer_autoconfirm': true,
        'phone_autoconfirm': false,
        'external': {'email': true},
      });
    }
    if (path.startsWith('/auth/v1/')) {
      return _jsonResponse(404, {'error': 'not_found'});
    }

    // ── PostgREST path rewrite (/rest/v1 → /) ────────────────────────────────
    if (path.startsWith('/rest/v1')) {
      final newPath = path.replaceFirst('/rest/v1', '');
      final newUrl =
          request.url.replace(path: newPath.isEmpty ? '/' : newPath);
      final newRequest = http.Request(request.method, newUrl)
        ..headers.addAll(request.headers);
      if (request is http.Request) {
        newRequest.bodyBytes = request.bodyBytes;
      }
      return _inner.send(newRequest);
    }

    return _inner.send(request);
  }

  // ── Sign-in ────────────────────────────────────────────────────────────────

  Future<http.StreamedResponse> _handleSignIn(http.BaseRequest request) async {
    try {
      final body = await _readBody(request);
      final data = json.decode(body) as Map<String, dynamic>;
      final email = (data['email'] ?? '') as String;
      final password = (data['password'] ?? '') as String;
      final origin = _origin(request);

      final res = await _inner.post(
        Uri.parse('$origin/rpc/client_login'),
        headers: _rpcHeaders(),
        body: json.encode({'p_email': email, 'p_password': password}),
      );

      final profile = json.decode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200 || profile['success'] != true) {
        final msg = (profile['message'] ?? 'Email ou senha incorretos') as String;
        return _authError(msg);
      }

      await _cacheUser(profile);
      return _jsonResponse(200, _buildAuthResp(profile));
    } catch (e) {
      return _jsonResponse(500, {'error': 'server_error', 'msg': '$e'});
    }
  }

  // ── Sign-up ────────────────────────────────────────────────────────────────

  Future<http.StreamedResponse> _handleSignUp(http.BaseRequest request) async {
    try {
      final body = await _readBody(request);
      final data = json.decode(body) as Map<String, dynamic>;
      final email = (data['email'] ?? '') as String;
      final password = (data['password'] ?? '') as String;
      final fullName =
          ((data['data'] as Map?)?['full_name'] ?? email.split('@')[0]) as String;
      final origin = _origin(request);

      final res = await _inner.post(
        Uri.parse('$origin/rpc/client_register'),
        headers: _rpcHeaders(),
        body: json.encode({
          'p_email': email,
          'p_password': password,
          'p_full_name': fullName,
        }),
      );

      final profile = json.decode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200 || profile['success'] != true) {
        final msg = (profile['message'] ?? 'Erro no cadastro') as String;
        return _jsonResponse(422, {
          'error': 'signup_failed',
          'msg': msg,
          'message': msg,
          'error_description': msg,
          'code': msg.contains('já') ? 'user_already_exists' : 'signup_failed',
        });
      }

      await _cacheUser(profile);
      return _jsonResponse(200, _buildAuthResp(profile));
    } catch (e) {
      return _jsonResponse(500, {'error': 'server_error', 'msg': '$e'});
    }
  }

  // ── Token refresh ──────────────────────────────────────────────────────────

  Future<http.StreamedResponse> _handleRefresh() async {
    final cached = await _loadCachedUser();
    if (cached == null) {
      return _jsonResponse(
          400, {'error': 'invalid_grant', 'msg': 'No session'});
    }
    return _jsonResponse(200, _buildAuthResp(cached));
  }

  // ── Get current user ───────────────────────────────────────────────────────

  Future<http.StreamedResponse> _handleGetUser() async {
    final cached = await _loadCachedUser();
    if (cached == null) {
      return _jsonResponse(401, {'error': 'invalid_token'});
    }
    return _jsonResponse(200, _userObject(cached));
  }

  // ── Sign-out ───────────────────────────────────────────────────────────────

  Future<http.StreamedResponse> _handleSignOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userCacheKey);
    return http.StreamedResponse(
      Stream<List<int>>.fromIterable([]),
      204,
      headers: {'content-type': 'application/json'},
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static Future<void> _cacheUser(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userCacheKey, json.encode(profile));
  }

  static Future<Map<String, dynamic>?> _loadCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_userCacheKey);
      if (raw == null) return null;
      return json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static String _origin(http.BaseRequest request) {
    final u = request.url;
    final port = u.hasPort &&
            !((u.scheme == 'https' && u.port == 443) ||
                (u.scheme == 'http' && u.port == 80))
        ? ':${u.port}'
        : '';
    return '${u.scheme}://${u.host}$port';
  }

  static Map<String, String> _rpcHeaders() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Profile': 'startflix',
        'Content-Profile': 'startflix',
      };

  static Future<String> _readBody(http.BaseRequest request) async {
    if (request is http.Request) {
      return utf8.decode(request.bodyBytes);
    }
    return '{}';
  }

  static Map<String, dynamic> _userObject(Map<String, dynamic> profile) {
    final userId = (profile['id'] ?? '') as String;
    final email = (profile['email'] ?? '') as String;
    final now = DateTime.now().toUtc().toIso8601String();
    return {
      'id': userId,
      'aud': 'authenticated',
      'role': 'authenticated',
      'email': email,
      'email_confirmed_at': now,
      'phone': '',
      'confirmed_at': now,
      'last_sign_in_at': now,
      'app_metadata': {'provider': 'email', 'providers': ['email']},
      'user_metadata':
          profile['full_name'] != null ? {'full_name': profile['full_name']} : {},
      'identities': [],
      'created_at': now,
      'updated_at': now,
    };
  }

  static Map<String, dynamic> _buildAuthResp(Map<String, dynamic> profile) {
    final userId = (profile['id'] ?? '') as String;
    // Use the real anon key so PostgREST accepts subsequent queries.
    // expiresAt = anon key expiry (year 2036) so gotrue-dart won't refresh soon.
    const expiresAt = 2094305048;
    return {
      'access_token': _anonKey,
      'token_type': 'bearer',
      'expires_in': expiresAt - (DateTime.now().millisecondsSinceEpoch ~/ 1000),
      'expires_at': expiresAt,
      'refresh_token': 'startflix-$userId',
      'user': _userObject(profile),
    };
  }

  http.StreamedResponse _authError(String msg) {
    return _jsonResponse(400, {
      'error': 'invalid_grant',
      'error_description': msg,
      'msg': msg,
      'message': msg,
    });
  }

  http.StreamedResponse _jsonResponse(int status, Map<String, dynamic> body) {
    final bytes = utf8.encode(json.encode(body));
    return http.StreamedResponse(
      Stream.fromIterable([bytes]),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
}
