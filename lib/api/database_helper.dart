import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHelper {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://tblylnfupwzrmwvfukpn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRibHlsbmZ1cHd6cm13dmZ1a3BuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg1NjA5MDYsImV4cCI6MjA2NDEzNjkwNn0.teg-Z_-ZZgUJWBLQkTOAjwaZop_ZmNoNOvtVgXr8tNU',
  );
  }
}