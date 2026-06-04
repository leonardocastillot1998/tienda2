import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_page.dart';
import 'services/auth_service.dart';
import 'theme/prestige_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jrwkxshvzbgcyosngzww.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impyd2t4c2h2emJnY3lvc25nend3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY3ODYxMDEsImV4cCI6MjA5MjM2MjEwMX0.rMUZ1-1miqGpTsZbs1xfkJGd-29k-ropUj4EZgiEkkI',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Client Loyalty',
      theme: buildPrestigeTheme(),
      home: LoginPage(authService: authService),
    );
  }
}
