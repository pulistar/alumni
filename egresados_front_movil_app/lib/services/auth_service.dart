import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl =
      'https://34c1-161-18-63-163.ngrok-free.app/api/egresados';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> login(String correo, String password) async {
    try {
      print('Intentando login con correo: $correo');
      print('URL del backend: $baseUrl/login');

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': correo, 'password': password}),
      );

      print('Código de respuesta: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        return {'ok': true};
      } else {
        return {'ok': false, 'message': data['message'] ?? 'Error en el login'};
      }
    } catch (e) {
      print('Error en login: $e');
      return {'ok': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> register(
    String nombre,
    String correo,
    String carrera,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'correo': correo,
          'carrera': carrera,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'ok': true};
      } else {
        return {
          'ok': false,
          'message': data['message'] ?? 'Error en el registro',
        };
      }
    } catch (e) {
      return {'ok': false, 'message': 'Error de conexión: $e'};
    }
  }
}
