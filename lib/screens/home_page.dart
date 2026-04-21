import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.username,
    required this.puntos,
    required this.authService,
  });

  final String username;
  final int puntos;
  final AuthService authService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _puntos;

  @override
  void initState() {
    super.initState();
    _puntos = widget.puntos;
  }

  Future<void> _logout() async {
    await widget.authService.logout();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LoginPage(authService: widget.authService),
      ),
    );
  }

  Future<void> _agregarPuntos(int valor) async {
    setState(() {
      _puntos += valor;
    });

    await widget.authService.savePoints(
      username: widget.username,
      points: _puntos,
    );

    if (valor < 0 && mounted) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Felicidades'),
          content: const Text('Has ganado un premio.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puntos y Recompensas'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, ${widget.username}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Puntos acumulados: $_puntos',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _agregarPuntos(10),
              icon: const Icon(Icons.add_circle),
              label: const Text('Ganar 10 puntos'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _puntos >= 50 ? () => _agregarPuntos(-50) : null,
              icon: const Icon(Icons.card_giftcard),
              label: const Text('Canjear premio (50 puntos)'),
            ),
            if (_puntos < 50)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Necesitas 50 puntos para canjear.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
