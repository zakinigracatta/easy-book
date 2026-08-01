class SupabaseConfig {
  static const String supabaseUrl = '';
  static const String supabaseAnonKey = '';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}