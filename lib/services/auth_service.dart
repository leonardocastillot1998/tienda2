import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

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
  SupabaseClient get _supabase => Supabase.instance.client;

  Future<void> signInWithGitHub() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.github,
      redirectTo: kIsWeb ? null : 'io.supabase.tienda2://login-callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<AuthResult> syncOAuthUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return const AuthResult(success: false, error: 'No session found');
    }

    final metadata = user.userMetadata ?? {};
    final username =
        metadata['preferred_username'] ??
        metadata['user_name'] ??
        user.email?.split('@').first ??
        user.id;
    final fullName = metadata['full_name'] ?? metadata['name'];
    final email = user.email;

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
          'email': email,
          'nombre_completo': fullName,
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
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Failed to sign out from Supabase: $e');
    }

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

  /// Adds a history entry for the given user into local shared preferences.
  /// The entry is an arbitrary map that should contain at least a `date`,
  /// `title` and `pointsSpent` fields to be displayed in the UI.
  Future<void> addHistoryEntry({
    required String username,
    required Map<String, dynamic> entry,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'history_\$username';
      final raw = prefs.getString(key);
      final List<dynamic> list = raw != null ? json.decode(raw) as List<dynamic> : [];
      list.insert(0, entry);
      await prefs.setString(key, json.encode(list));
    } catch (e) {
      debugPrint('Failed to add history entry: $e');
    }
  }

  /// Returns the history list for the given user from shared preferences.
  Future<List<Map<String, dynamic>>> getHistory(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('history_\$username');
      if (raw == null || raw.isEmpty) return [];
      final data = json.decode(raw) as List<dynamic>;
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('Failed to read history: $e');
      return [];
    }
  }

  /// Adds a custom product to local storage for the given user.
  Future<void> addCustomProduct({
    required String username,
    required Map<String, dynamic> product,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'custom_products_\$username';
      final raw = prefs.getString(key);
      final List<dynamic> list = raw != null ? json.decode(raw) as List<dynamic> : [];
      list.insert(0, product);
      await prefs.setString(key, json.encode(list));
    } catch (e) {
      debugPrint('Failed to add custom product: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCustomProducts(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('custom_products_\$username');
      if (raw == null || raw.isEmpty) return [];
      final data = json.decode(raw) as List<dynamic>;
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('Failed to read custom products: $e');
      return [];
    }
  }

  Future<String?> updateUserProfile({
    required String username,
    String? nombreCompleto,
    String? email,
    String? telefono,
    String? fechaNacimiento,
    String? address,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (nombreCompleto != null && nombreCompleto.trim().isNotEmpty) {
        updates['nombre_completo'] = nombreCompleto.trim();
      }
      if (email != null && email.trim().isNotEmpty) {
        updates['email'] = email.trim();
      }
      if (telefono != null && telefono.trim().isNotEmpty) {
        updates['numero_de_telefono'] = telefono.trim();
      }
      if (fechaNacimiento != null && fechaNacimiento.trim().isNotEmpty) {
        updates['fecha_de_nacimiento'] = fechaNacimiento.trim();
      }
      if (address != null && address.trim().isNotEmpty) {
        updates['address'] = address.trim();
      }

      if (updates.isEmpty) {
        return null;
      }

      await _supabase.from('usuarios').update(updates).eq('username', username);
      return null;
    } catch (e) {
      // Ignore in production UI, but keep the actual error visible in debug logs.
      debugPrint('Failed to update profile: $e');
      return e.toString();
    }
  }

  /// Calculates the closest reward and progress towards it
  /// Returns a map with rewardInfo and progress percentage
  static Map<String, dynamic>? calculateClosestRewardProgress(
    int currentPoints,
    List<Map<String, dynamic>> products,
  ) {
    if (products.isEmpty) return null;

    int pointsFor(Map<String, dynamic> product) {
      final value = product['points'];
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    final sortedProducts = List<Map<String, dynamic>>.from(products)
      ..sort((a, b) => pointsFor(a).compareTo(pointsFor(b)));

    final redeemableRewards = sortedProducts
        .where((product) => pointsFor(product) <= currentPoints)
        .toList();

    final hasRedeemableReward = redeemableRewards.isNotEmpty;
    final closestReward = hasRedeemableReward
        ? redeemableRewards.last
        : sortedProducts.firstWhere(
            (product) => pointsFor(product) > currentPoints,
            orElse: () => sortedProducts.last,
          );
    final pointsRequired = pointsFor(closestReward);
    final canRedeem = currentPoints >= pointsRequired;
    final progressPercentage = canRedeem
        ? 100.0
        : (pointsRequired <= 0
              ? 0.0
              : (currentPoints / pointsRequired * 100).clamp(0, 100).toDouble());

    return {
      'rewardTitle': closestReward['title'] ?? 'Unknown Reward',
      'pointsRequired': pointsRequired,
      'currentPoints': currentPoints,
      'pointsNeeded': canRedeem ? 0 : (pointsRequired - currentPoints),
      'progress': progressPercentage,
      'canRedeem': canRedeem,
      'hasRedeemableReward': hasRedeemableReward,
      'statusLabel': hasRedeemableReward ? 'Listo para canjear!' : 'Progreso hacia recompensa',
      'message': hasRedeemableReward
          ? 'Puedes canjear esta recompensa ahora'
          : 'Te faltan ${(pointsRequired - currentPoints).clamp(0, pointsRequired)} puntos',
    };
  }

  static Map<String, dynamic> calculateRewardProgress(
    int currentPoints,
    int rewardPoints,
  ) {
    final canRedeem = currentPoints >= rewardPoints;
    final pointsNeeded = canRedeem ? 0 : (rewardPoints - currentPoints);
    final progressPercentage = rewardPoints <= 0
        ? 0.0
        : (currentPoints / rewardPoints * 100).clamp(0, 100).toDouble();

    return {
      'progress': canRedeem ? 100.0 : progressPercentage,
      'canRedeem': canRedeem,
      'pointsNeeded': pointsNeeded,
      'statusLabel': canRedeem ? 'Listo para canjear!' : 'Progreso hacia este premio',
      'message': canRedeem
          ? 'Puedes canjear este producto ahora'
          : 'Te faltan $pointsNeeded puntos',
    };
  }

  Future<Map<String, dynamic>?> getClosestRewardProgress(int currentPoints) async {
    try {
      final products = await _supabase.from('productos').select();
      final typedProducts = products
          .whereType<Map<String, dynamic>>()
          .toList();

      return calculateClosestRewardProgress(currentPoints, typedProducts);
    } catch (e) {
      debugPrint('Error calculating closest reward: $e');
      return null;
    }
  }
}
