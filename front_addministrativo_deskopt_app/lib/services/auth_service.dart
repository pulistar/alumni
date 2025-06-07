import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl =
      'https://34c1-161-18-63-163.ngrok-free.app/api/administrativos';
  static const String _tokenKey = 'admin_token';
  final _storage = const FlutterSecureStorage();

  Future<bool> login(String correo, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'correo': correo, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveToken(data['token']);
        return true;
      }
      return false;
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  Future<void> _saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
}
