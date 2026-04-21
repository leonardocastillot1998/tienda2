import 'package:flutter/material.dart';

import 'screens/login_page.dart';
import 'services/auth_service.dart';
import 'theme/prestige_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Prestige Exchange',
      theme: buildPrestigeTheme(),
      home: LoginPage(authService: authService),
    );
  }
}
