import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Excepción personalizada para errores de autenticación
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final String _baseUrl = 'https://jolusapplication.orionnx.com';

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login.php'),
        body: jsonEncode({
          'correo': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        return data['user'];
      } else {
        throw AuthException(data['message'] ?? 'Error al iniciar sesión');
      }
    } catch (e) {
      debugPrint('Error en login: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Error de conexión con el servidor');
    }
  }

  Future<String?> register({
    required String email,
    required String password,
    required String nombres,
    required String apellidos,
    String? telefono,
    String? direccion,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register.php'),
        body: jsonEncode({
          'correo': email,
          'password': password,
          'nombres': nombres,
          'apellidos': apellidos,
          'telefono': telefono ?? '',
          'direccion': direccion ?? '',
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        return data['user_id']?.toString();
      } else {
        throw AuthException(data['message'] ?? 'Error al registrar usuario');
      }
    } catch (e) {
      debugPrint('Error en registro: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Error al procesar el registro');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reset_password.php'),
        body: jsonEncode({'correo': email}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode != 200 || data['status'] != 'success') {
        throw AuthException(data['message'] ?? 'No se pudo enviar el correo de recuperación');
      }
    } catch (e) {
      debugPrint('Error en resetPassword: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Error al solicitar restablecimiento de contraseña');
    }
  }

  /// Método utilizado en update_password_screen.dart
  Future<void> updatePassword(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) throw AuthException('Sesión no encontrada');

      final response = await http.post(
        Uri.parse('$_baseUrl/update_password.php'),
        body: jsonEncode({
          'user_id': userId,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode != 200 || data['status'] != 'success') {
        throw AuthException(data['message'] ?? 'Error al actualizar la contraseña');
      }
    } catch (e) {
      debugPrint('Error en updatePassword: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Error de conexión al actualizar contraseña');
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'user_id', 'user_name', 'user_subname', 'user_email',
      'user_photo_url', 'user_phone', 'user_address', 'user_is_admin'
    ];
    for (var key in keys) {
      await prefs.remove(key);
    }
  }
}