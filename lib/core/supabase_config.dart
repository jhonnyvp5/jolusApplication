import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://ezsutogtcoeuzkzwtesk.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV6c3V0b2d0Y29ldXprend0ZXNrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg0NjMwNzksImV4cCI6MjA3NDAzOTA3OX0.HQFUHYunbDi-TGSXagNGY1fxdlrwaYVudbs9H1m5oZU';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      publishableKey: anonKey,
    );
  }
}
