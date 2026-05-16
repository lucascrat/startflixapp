import 'package:supabase_flutter/supabase_flutter.dart';

/// Helper class to access Supabase with the correct schema
class SupabaseHelper {
  static const String defaultSchema = 'startflix';

  /// Get Supabase client with the custom schema
  static SupabaseQueryBuilder from(String table) {
    // Default to startflix schema for tables
    return Supabase.instance.client.schema(defaultSchema).from(table);
  }

  /// Get direct table access (no views) - Use for updates/inserts
  static SupabaseQueryBuilder table(String name) {
    return Supabase.instance.client.schema(defaultSchema).from(name);
  }

  /// Get the raw Supabase client (for auth, storage, etc.)
  static SupabaseClient get client => Supabase.instance.client;

  /// Get auth instance
  static GoTrueClient get auth => Supabase.instance.client.auth;

  /// Get storage instance
  static SupabaseStorageClient get storage => Supabase.instance.client.storage;

  /// Get realtime instance
  static RealtimeClient get realtime => Supabase.instance.client.realtime;

  /// Call an RPC function
  static PostgrestFilterBuilder<dynamic> rpc(
    String fn, {
    Map<String, dynamic>? params,
  }) {
    return Supabase.instance.client.rpc(fn, params: params);
  }
}
