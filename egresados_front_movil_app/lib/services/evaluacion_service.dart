import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EvaluacionService {
  final String baseUrl =
      'https://34c1-161-18-63-163.ngrok-free.app/api/egresados';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> enviarEvaluacion({
    required String empleoActual,
    required bool relacionadoCarrera,
    required List<String> competenciasUtiles,
    String? sugerencias,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        return {'ok': false, 'message': 'Usuario no autenticado'};
      }

      final url = Uri.parse('$baseUrl/evaluacion');

      final body = json.encode({
        'empleo_actual': empleoActual,
        'relacionado_carrera': relacionadoCarrera,
        'competencias_utiles': competenciasUtiles,
        'sugerencias': sugerencias ?? '',
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'ok': true,
          'message': data['message'] ?? 'Evaluación enviada con éxito',
        };
      } else {
        final data = json.decode(response.body);
        return {
          'ok': false,
          'message': data['message'] ?? 'Error al enviar evaluación',
        };
      }
    } catch (e) {
      return {'ok': false, 'message': 'Error de conexión: $e'};
    }
  }
}
