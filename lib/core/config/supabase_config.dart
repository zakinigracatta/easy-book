class SupabaseConfig {
  static const String supabaseUrl = 'https://YOUR_SUPABASE_URL.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  static bool get isConfigured =>
      supabaseUrl != 'https://YOUR_SUPABASE_URL.supabase.co' &&
      supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';
}
