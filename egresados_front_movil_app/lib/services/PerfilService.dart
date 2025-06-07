import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PerfilService {
  final String baseUrl =
      'https://34c1-161-18-63-163.ngrok-free.app/api/egresados';

  Future<bool?> obtenerEstadoHabilitacion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/perfil'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['habilitado'] as bool; // Extraemos solo habilitado
      } else {
        print('Error al obtener perfil: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return null;
    }
  }
}
