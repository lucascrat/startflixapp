import 'package:supabase_flutter/supabase_flutter.dart';
import 'm3u_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _profileCacheKey = 'cached_user_profile';

  // Helper to access tables with correct schema (Strictly using startflix schema)
  SupabaseQueryBuilder _from(String table) {
    return _supabase.schema('startflix').from(table);
  }

  // Simple getter for the internal email, we can parse username from it if needed
  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Get cached user profile
  Future<Map<String, dynamic>?> getCachedUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_profileCacheKey);
      if (data == null) return null;
      return json.decode(data);
    } catch (e) {
      return null;
    }
  }

  // INTERNAL HELPER: Converts simple username to email
  String _emailFromUsername(String username) {
    if (username.contains('@')) return username; // Fallback if already an email
    return '${username.trim()}@startflix.app';
  }

  // INTERNAL HELPER: Gets username from email for display if needed
  String get currentUsername {
    final email = currentUser?.email ?? '';
    return email.split('@')[0];
  }

  Future<AuthResponse> signIn({
    required String username,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: _emailFromUsername(username),
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String username,
    required String password,
  }) async {
    return await _supabase.auth.signUp(
      email: _emailFromUsername(username),
      password: password,
    );
  }

  Future<void> signOut() async {
    await M3uService().releaseSignal();
    await _supabase.auth.signOut();
  }

  // Profile Management

  /// Get current user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final response = await _from(
        'profiles',
      ).select().eq('id', user.id).single();

      // Cache the profile
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileCacheKey, json.encode(response));

      return response;
    } catch (e) {
      print('Error fetching profile: $e');
      // Self-healing: If profile missing, create it
      if (user.email != null) {
        try {
          print('Attempting to create missing profile for ${user.id}...');
          final newProfile = {
            'id': user.id,
            'email': user.email,
            'full_name':
                user.userMetadata?['full_name'] ?? user.email!.split('@')[0],
            'role': 'client',
            'is_active': true,
          };
          await _from('profiles').insert(newProfile);
          print('Profile created successfully via fallback.');
          return newProfile;
        } catch (createErr) {
          print('Failed to create fallback profile: $createErr');
        }
      }

      // Return cached if available as last resort
      return await getCachedUserProfile();
    }
  }

  /// Get all profiles (Admin only)
  Future<List<Map<String, dynamic>>> getAllProfiles() async {
    try {
      print('AuthService: Fetching all profiles...');
      final response = await _from(
        'profiles',
      ).select().order('created_at', ascending: false);
      print('AuthService: Got ${response.length} profiles');
      for (var p in response) {
        print('  - Profile: ${p['email']} (role: ${p['role']})');
      }
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching profiles: $e');
      return [];
    }
  }

  /// Update a user's profile (Admin only)
  Future<void> updateProfile({
    required String id,
    String? fullName,
    String? m3uUrl,
    bool? isActive,
    bool? adsEnabled,
    DateTime? expirationDate,
    String? role,
    String? appImageUrl,
    String? appMac,
    String? appCredsPassword,
    String? tvProviderName,
    String? tvUsername,
    String? tvPassword,
    String? tvDns,
    double? lineCost,
    String? avatarUrl,
    String? externalPanelUrl,
    String? appId,
    String? appProviderUrl,
    String? appUsername,
    String? appPasswordApp,
    String? phone,
    DateTime? rewardedUntil,
  }) async {
    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;
    if (m3uUrl != null) updates['m3u_url'] = m3uUrl;
    if (isActive != null) updates['is_active'] = isActive;
    if (adsEnabled != null) updates['ads_enabled'] = adsEnabled;
    if (expirationDate != null) {
      updates['expiration_date'] = expirationDate.toIso8601String();
    }
    if (rewardedUntil != null) {
      updates['rewarded_until'] = rewardedUntil.toIso8601String();
    }
    if (role != null) updates['role'] = role;
    if (appImageUrl != null) updates['app_image_url'] = appImageUrl;
    if (appMac != null) updates['app_mac'] = appMac;
    if (appCredsPassword != null) {
      updates['app_creds_password'] = appCredsPassword;
    }
    if (lineCost != null) updates['line_cost'] = lineCost;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (externalPanelUrl != null) {
      updates['external_panel_url'] = externalPanelUrl;
    }

    // App selection and credentials
    if (appId != null) updates['app_id'] = appId.isEmpty ? null : appId;
    if (appProviderUrl != null) updates['app_provider_url'] = appProviderUrl;
    if (appUsername != null) updates['app_username'] = appUsername;
    if (appPasswordApp != null) updates['app_password_app'] = appPasswordApp;

    // Legacy TV fields (optional update if table coluimns exist, but we prioritize media_accounts)
    if (tvProviderName != null) updates['tv_provider_name'] = tvProviderName;
    if (tvUsername != null) updates['tv_username'] = tvUsername;
    if (tvPassword != null) updates['tv_password'] = tvPassword;
    if (tvDns != null) updates['tv_dns'] = tvDns;

    await _from('profiles').update(updates).eq('id', id);
  }

  // --- Payments ---

  /// Get payments for specific user or all if userId is null (and is admin)
  Future<List<Map<String, dynamic>>> getPayments({String? userId}) async {
    try {
      var query = _from('payments').select('*, profiles(full_name)');

      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error fetching payments: $e');
      return [];
    }
  }

  /// Register a manual payment (Admin)
  Future<void> registerPayment({
    required String userId,
    required double amount,
    String? description,
  }) async {
    await _from(
      'payments',
    ).insert({'user_id': userId, 'amount': amount, 'description': description});
  }

  // --- Media/Inventory Management (V3) ---

  // Renamed to getClientTvs for compatibility, but queries media_accounts
  Future<List<Map<String, dynamic>>> getClientTvs(String userId) async {
    try {
      final response = await _from(
        'media_accounts',
      ).select().eq('user_id', userId).order('created_at');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching Media Accounts: $e');
      return [];
    }
  }

  Future<void> addClientTv({
    required String userId,
    String? providerName,
    String? username,
    String? password,
    String? dns,
  }) async {
    // Adds directly to a user (Direct Assignment)
    await _from('media_accounts').insert({
      'user_id': userId,
      'provider_name': providerName,
      'username': username,
      'password': password,
      'dns': dns,
    });
  }

  Future<void> deleteClientTv(String id) async {
    // Deleting actually deletes it or sets user_id null?
    // "Delete" usually implies removing the access.
    // If we want to return to stock, we update user_id = null.
    // But if Admin clicks delete, they might mean "Remove this credential entirely".
    // Let's assume Delete = Delete.
    await _from('media_accounts').delete().eq('id', id);
  }

  // INVENTORY METHODS

  Future<Map<String, int>> getInventoryStats() async {
    try {
      final total = await _from('media_accounts').count();
      final used = await _from(
        'media_accounts',
      ).count().not('user_id', 'is', null);

      return {'total': total, 'used': used, 'free': total - used};
    } catch (e) {
      print("Error stats: $e");
      return {'total': 0, 'used': 0, 'free': 0};
    }
  }

  Future<void> addInventoryAccount({
    required String providerName,
    required String username,
    required String password,
    required String dns,
  }) async {
    print("ATTEMPTING to add to inventory: $providerName, $username");

    // Check if table exists (simple query)
    try {
      await _from('media_accounts').select('id').limit(1);
      print("Table 'media_accounts' exists and is readable.");
    } catch (e) {
      print(
        "CRITICAL ERROR: Table 'media_accounts' might be missing or RLS blocking read: $e",
      );
    }

    try {
      final response = await _from('media_accounts').insert({
        'provider_name': providerName,
        'username': username,
        'password': password,
        'dns': dns,
        'user_id': null,
      }).select();

      print("Inventory added successfully: $response");
    } catch (e) {
      print("Error adding inventory (Direct Insert): $e");
      throw "Erro ao salvar no banco: $e. Verifique se a tabela 'media_accounts' existe.";
    }
  }

  /// Check if the current user is an admin
  Future<bool> isUserAdmin() async {
    final user = currentUser;
    if (user == null) return false;

    if (user.email == 'admin@startflix.app' ||
        user.email == 'admin@startflix.com') {
      return true;
    }

    try {
      final response = await _from(
        'admins',
      ).select().eq('id', user.id).maybeSingle();

      return response != null;
    } catch (e) {
      print('Admin check failed: $e');
      return false;
    }
  }

  /// Test database connection
  Future<String> testConnection() async {
    try {
      await _from('profiles').select().limit(1);
      return "Conexão OK! Banco respondendo.";
    } catch (e) {
      return "Erro de Conexão: $e";
    }
  }

  Future<void> createUser({
    required String username,
    required String password,
    required String fullName,
    String? avatarUrl,
  }) async {
    final email = _emailFromUsername(username);
    print("AuthService: Iniciando cadastro para $email");

    // 1. Create Auth User
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    print(
      "AuthService: Cadastro realizado. Session: ${response.session != null}",
    );

    // 2. Se o cadastro funcionou mas não logou automático (devido a config do Supabase)
    // Vamos realizar o login logo em seguida
    if (response.session == null) {
      print("AuthService: Realizando login manual pós-cadastro...");
      await signIn(username: username, password: password);
    }

    // 3. O trigger 'on_auth_user_created' no banco já deve ter criado o perfil.
    // Vamos apenas atualizar o avatar se fornecido.
    if (avatarUrl != null && _supabase.auth.currentUser != null) {
      try {
        await _from('profiles')
            .update({'avatar_url': avatarUrl})
            .eq('id', _supabase.auth.currentUser!.id);
        print("AuthService: Avatar atualizado com sucesso.");
      } catch (e) {
        print('AuthService: Erro ao atualizar avatar: $e');
      }
    }
  }
  // --- Admin User Management ---

  Future<void> adminUpdateUserCredentials({
    required String userId,
    required String newUsername,
    required String newPassword,
  }) async {
    final newEmail = _emailFromUsername(newUsername);

    await _supabase.rpc(
      'admin_update_user_credentials',
      params: {
        'target_user_id': userId,
        'new_email': newEmail,
        'new_password': newPassword,
      },
    );
  }

  /// Renew subscription via external panel automation
  Future<Map<String, dynamic>> renewSubscription({
    required String userId,
    required String externalPanelUrl,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'renew-subscription',
        body: {'userId': userId, 'externalPanelUrl': externalPanelUrl},
      );

      if (response.status == 200) {
        return {
          'success': true,
          'message': 'Assinatura renovada com sucesso!',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erro ao renovar: ${response.data}',
        };
      }
    } catch (e) {
      print('Error renewing subscription: $e');
      return {
        'success': false,
        'message': 'Erro ao conectar com o servidor: $e',
      };
    }
  }
  // --- Mass Actions ---

  /// Renew all active users by 30 days
  Future<Map<String, dynamic>> massRenewUsers() async {
    try {
      // Fetch all active profiles
      final profiles = await _from('profiles').select();
      int successCount = 0;
      int errorCount = 0;

      for (var profile in profiles) {
        try {
          final String? expString = profile['expiration_date'];
          DateTime currentExp = expString != null
              ? DateTime.parse(expString).toLocal()
              : DateTime.now();

          // If expired, start from now. If active, add to existing date.
          if (currentExp.isBefore(DateTime.now())) {
            currentExp = DateTime.now();
          }

          final newExp = currentExp.add(const Duration(days: 30));

          await updateProfile(
            id: profile['id'],
            expirationDate: newExp,
            isActive: true, // Ensure they are active
          );
          successCount++;
        } catch (e) {
          print('Error renewing user ${profile['id']}: $e');
          errorCount++;
        }
      }

      return {
        'success': true,
        'message': '$successCount usuários renovados. $errorCount erros.',
        'successCount': successCount,
        'errorCount': errorCount,
      };
    } catch (e) {
      print('Error in mass renew: $e');
      return {
        'success': false,
        'message': 'Erro crítico ao renovar em massa: $e',
      };
    }
  }

  /// Get dynamic ad reward duration from system settings
  Future<int> getAdRewardDuration() async {
    try {
      final response = await _from('system_settings')
          .select('value')
          .eq('id', 'ad_config')
          .maybeSingle();

      if (response != null && response['value'] != null) {
        return response['value']['reward_duration_minutes'] ?? 90;
      }
    } catch (e) {
      print('Error fetching ad reward duration: $e');
    }
    return 90; // Fallback to 1 hour and 30 minutes
  }

  /// Login using a quick access code
  Future<Map<String, dynamic>?> loginWithCode(String code) async {
    try {
      final response = await _from('access_codes')
          .select()
          .eq('code', code.toUpperCase())
          .eq('is_active', true)
          .maybeSingle();

      if (response != null) {
        return {
          'm3u_url': response['m3u_url'],
          'code': response['code'],
          'description': response['description'],
        };
      }
    } catch (e) {
      print('Error validating access code: $e');
    }
    return null;
  }
}
