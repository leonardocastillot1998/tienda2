import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const String kUsersKey = 'users';
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
  String pointsKeyFor(String username) => 'puntos:$username';

  Future<Map<String, String>> _readUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kUsersKey);
    if (raw == null || raw.isEmpty) {
      return {};
    }

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

  Future<void> ensureDefaultUser() async {
    final users = await _readUsers();
    if (!users.containsKey('leonardo')) {
      users['leonardo'] = '1234';
      await _saveUsers(users);
    }
  }

  Future<AuthSession?> checkSavedSession() async {
    await ensureDefaultUser();

    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(kLoggedInKey) ?? false;
    final currentUser = prefs.getString(kUsernameKey) ?? '';

    if (!loggedIn || currentUser.isEmpty) {
      return null;
    }

    final points = prefs.getInt(pointsKeyFor(currentUser)) ?? 20;
    await prefs.setInt(pointsKeyFor(currentUser), points);

    return AuthSession(username: currentUser, points: points);
  }

  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    final users = await _readUsers();

    if (users.containsKey(username) && users[username] == password) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kLoggedInKey, true);
      await prefs.setString(kUsernameKey, username);

      final points = prefs.getInt(pointsKeyFor(username)) ?? 20;
      await prefs.setInt(pointsKeyFor(username), points);

      return AuthResult(
        success: true,
        session: AuthSession(username: username, points: points),
      );
    }

    return const AuthResult(
      success: false,
      error:
          'Usuario o contrasena invalidos. Crea cuenta o prueba leonardo / 1234',
    );
  }

  Future<AuthResult> register({
    required String username,
    required String password,
  }) async {
    final users = await _readUsers();

    if (users.containsKey(username)) {
      return const AuthResult(
        success: false,
        error: 'El usuario ya existe. Elige otro nombre.',
      );
    }

    users[username] = password;
    await _saveUsers(users);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(pointsKeyFor(username), 20);
    await prefs.setBool(kLoggedInKey, true);
    await prefs.setString(kUsernameKey, username);

    return AuthResult(
      success: true,
      session: AuthSession(username: username, points: 20),
    );
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(pointsKeyFor(username), points);
  }
}
