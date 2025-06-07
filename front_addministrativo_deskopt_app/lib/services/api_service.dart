import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // Método genérico GET
  static Future<dynamic> getRequest(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      final response = await http.get(url);
      return _processResponse(response);
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  // Método genérico POST
  static Future<dynamic> postRequest(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  // Método genérico PUT
  static Future<dynamic> putRequest(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  // Método genérico DELETE
  static Future<dynamic> deleteRequest(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      final response = await http.delete(url);
      return _processResponse(response);
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  // Ejemplo de uso: login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    return await postRequest('login', {
      'email': email,
      'password': password,
    });
  }

  // Procesamiento de la respuesta
  static dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error en la petición: ${response.statusCode} - ${response.body}');
    }
  }
}
