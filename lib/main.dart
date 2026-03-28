import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kUsersKey = 'users';
const String kLoggedInKey = 'loggedIn';
const String kUsernameKey = 'username';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tienda Puntos y Recompensas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkSavedSession();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<Map<String, String>> _readUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kUsersKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return data.map((key, value) => MapEntry(key, value.toString()));
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveUsers(Map<String, String> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kUsersKey, jsonEncode(users));
  }

  Future<void> _ensureDefaultUser() async {
    final users = await _readUsers();
    if (!users.containsKey('leonardo')) {
      users['leonardo'] = '1234';
      await _saveUsers(users);
    }
  }

  String _pointsKeyFor(String username) => 'puntos:$username';

  Future<void> _checkSavedSession() async {
    setState(() => _isLoading = true);

    await _ensureDefaultUser();

    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(kLoggedInKey) ?? false;
    final currentUser = prefs.getString(kUsernameKey) ?? '';

    if (loggedIn && currentUser.isNotEmpty) {
      final puntos = prefs.getInt(_pointsKeyFor(currentUser)) ?? 20;
      await prefs.setInt(_pointsKeyFor(currentUser), puntos);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(username: currentUser, puntos: puntos),
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _error = null;
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final users = await _readUsers();

    if (users.containsKey(username) && users[username] == password) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kLoggedInKey, true);
      await prefs.setString(kUsernameKey, username);

      final puntaje = prefs.getInt(_pointsKeyFor(username)) ?? 20;
      await prefs.setInt(_pointsKeyFor(username), puntaje);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(username: username, puntos: puntaje),
        ),
      );
    } else {
      setState(() {
        _error =
            'Usuario o contraseña inválidos. Crea cuenta o prueba leonardo / 1234';
      });
      setState(() => _isLoading = false);
    }
  }

  Future<void> _goToRegister() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterPage()));
    if (!mounted) return;
    _checkSavedSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio de sesión')),
      backgroundColor: Colors.lightBlue.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: _isLoading
              ? const CircularProgressIndicator()
              : Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 120,
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.storefront,
                                size: 68,
                                color: Colors.blueAccent,
                              ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: 'Usuario'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el usuario';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa la contraseña';
                          }
                          if (value.length < 4) {
                            return 'La contraseña debe tener al menos 4 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _login,
                        child: const SizedBox(
                          width: double.infinity,
                          child: Center(child: Text('Entrar')),
                        ),
                      ),
                      TextButton(
                        onPressed: _goToRegister,
                        child: const Text('Crear cuenta'),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _newUserController = TextEditingController();
  final _newPassController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<Map<String, String>> _readUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kUsersKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return data.map((key, value) => MapEntry(key, value.toString()));
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveUsers(Map<String, String> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kUsersKey, jsonEncode(users));
  }

  String _pointsKeyFor(String username) => 'puntos:$username';

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final username = _newUserController.text.trim();
    final password = _newPassController.text;

    final users = await _readUsers();

    if (users.containsKey(username)) {
      setState(() {
        _error = 'El usuario ya existe. Elige otro nombre.';
        _isLoading = false;
      });
      return;
    }

    users[username] = password;
    await _saveUsers(users);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKeyFor(username), 20);
    await prefs.setBool(kLoggedInKey, true);
    await prefs.setString(kUsernameKey, username);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomePage(username: username, puntos: 20),
      ),
    );

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _newUserController.dispose();
    _newPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      backgroundColor: Colors.lightBlue.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: _isLoading
              ? const CircularProgressIndicator()
              : Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _newUserController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de usuario',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el nombre de usuario';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _newPassController,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa la contraseña';
                          }
                          if (value.length < 4) {
                            return 'La contraseña debe tener al menos 4 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _register,
                        child: const SizedBox(
                          width: double.infinity,
                          child: Center(child: Text('Crear cuenta')),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String username;
  final int puntos;

  const HomePage({super.key, required this.username, required this.puntos});

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

  String _pointsKeyFor(String username) => 'puntos:$username';

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kLoggedInKey, false);
    await prefs.remove(kUsernameKey);

    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  Future<void> _agregarPuntos(int valor) async {
    setState(() {
      _puntos += valor;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKeyFor(widget.username), _puntos);

    if (valor < 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¡Felicidades!'),
          content: const Text('Has ganado un premio'),
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
