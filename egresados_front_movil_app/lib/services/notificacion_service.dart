import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificacionService {
  final String baseUrl =
      'https://34c1-161-18-63-163.ngrok-free.app/api/egresados';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Map<String, dynamic>>> obtenerNotificaciones() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/notificaciones'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['notificaciones']);
      }

      return [];
    } catch (e) {
      print('Error al obtener notificaciones: $e');
      return [];
    }
  }

  Future<bool> marcarComoLeida(String notificacionId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return false;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/notificaciones/$notificacionId/leer'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al marcar notificación como leída: $e');
      return false;
    }
  }

  Future<int> obtenerNotificacionesNoLeidas() async {
    try {
      final notificaciones = await obtenerNotificaciones();
      return notificaciones.where((n) => !n['leida']).length;
    } catch (e) {
      print('Error al obtener notificaciones no leídas: $e');
      return 0;
    }
  }
}
