import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String kLoggedInKey = 'loggedIn';
const String kUsernameKey = 'username';

class AuthSession {
  const AuthSession({required this.username, required this.points});

  final String username;
  final int points;
}

class AuthResult {
  const AuthResult({required this.success, this.error, this.session});

  final bool success;
  final String? error;
  final AuthSession? session;
}

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<void> signInWithGitHub() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.github,
      redirectTo: kIsWeb ? null : 'io.supabase.tienda2://login-callback',
    );
  }

  Future<AuthResult> syncOAuthUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return const AuthResult(success: false, error: 'No session found');
    }

    final username = user.email ?? user.id;

    try {
      final existingUser = await _supabase
          .from('usuarios')
          .select('points')
          .eq('username', username)
          .maybeSingle();

      int points = 20;

      if (existingUser == null) {
        await _supabase.from('usuarios').insert({
          'username': username,
          'password': 'oauth_user_no_password',
          'points': points,
        });
      } else {
        points = existingUser['points'] as int;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kLoggedInKey, true);
      await prefs.setString(kUsernameKey, username);

      return AuthResult(
        success: true,
        session: AuthSession(username: username, points: points),
      );
    } catch (e) {
      return const AuthResult(success: false, error: 'Error syncing user data');
    }
  }

  Future<AuthSession?> checkSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(kLoggedInKey) ?? false;
    final currentUser = prefs.getString(kUsernameKey) ?? '';

    if (!loggedIn || currentUser.isEmpty) {
      return null;
    }

    try {
      final response = await _supabase
          .from('usuarios')
          .select('points')
          .eq('username', currentUser)
          .maybeSingle();

      if (response != null) {
        return AuthSession(
          username: currentUser,
          points: response['points'] as int,
        );
      }
    } catch (_) {
      // Ignoramos error y regresamos el sesion guardada si falla la conexion
    }

    return AuthSession(username: currentUser, points: 0);
  }

  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    try {
      final data = await _supabase
          .from('usuarios')
          .select('password, points')
          .eq('username', username)
          .maybeSingle();

      if (data == null) {
        return const AuthResult(success: false, error: 'Usuario no encontrado');
      }

      if (data['password'] != password) {
        return const AuthResult(success: false, error: 'Contrasena invalida');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kLoggedInKey, true);
      await prefs.setString(kUsernameKey, username);

      return AuthResult(
        success: true,
        session: AuthSession(username: username, points: data['points'] as int),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Error al conectar con el servidor',
      );
    }
  }

  Future<AuthResult> register({
    required String username,
    required String password,
  }) async {
    try {
      final existingUser = await _supabase
          .from('usuarios')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      if (existingUser != null) {
        return const AuthResult(
          success: false,
          error: 'El usuario ya existe. Elige otro nombre.',
        );
      }

      await _supabase.from('usuarios').insert({
        'username': username,
        'password': password,
        'points': 20,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kLoggedInKey, true);
      await prefs.setString(kUsernameKey, username);

      return AuthResult(
        success: true,
        session: AuthSession(username: username, points: 20),
      );
    } catch (e) {
      return const AuthResult(success: false, error: 'Error en el registro');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kLoggedInKey, false);
    await prefs.remove(kUsernameKey);
  }

  Future<void> savePoints({
    required String username,
    required int points,
  }) async {
    try {
      await _supabase
          .from('usuarios')
          .update({'points': points})
          .eq('username', username);
    } catch (e) {
      // Ignore
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String username) async {
    try {
      final data = await _supabase
          .from('usuarios')
          .select(
            'nombre_completo, email, numero_de_telefono, fecha_de_nacimiento, address, points',
          )
          .eq('username', username)
          .maybeSingle();
      return data;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateUserProfile({
    required String username,
    String? nombreCompleto,
    String? email,
    String? telefono,
    String? fechaNacimiento,
    String? address,
  }) async {
    try {
      await _supabase
          .from('usuarios')
          .update({
            'nombre_completo': nombreCompleto,
            'email': email,
            'numero_de_telefono': telefono,
            'fecha_de_nacimiento': fechaNacimiento,
            'address': address,
          })
          .eq('username', username);
      return true;
    } catch (e) {
      return false;
    }
  }
}
