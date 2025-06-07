import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'auth_service.dart';

class AdministrativoService {
  final AuthService _authService = AuthService();
  final String baseUrl =
      AuthService().baseUrl.replaceAll('/api/administrativos', '');

  Future<Map<String, dynamic>> subirExcelEgresados(File archivo) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/administrativos/habilitar-egresados'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'archivo',
          archivo.path,
          contentType: MediaType(
            'application',
            'vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.body,
        };
      } else {
        return {
          'success': false,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> listarEgresados({
    String? nombre,
    String? carrera,
    bool? habilitado,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final queryParams = {
        if (nombre != null && nombre.isNotEmpty) 'nombre': nombre,
        if (carrera != null && carrera.isNotEmpty) 'carrera': carrera,
        if (habilitado != null) 'habilitado': habilitado.toString(),
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$baseUrl/api/administrativos/egresados')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> listarEgresadosConEvaluacion() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/administrativos/evaluaciones'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Respuesta del backend: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Datos decodificados: $data'); // Debug
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': response.body,
        };
      }
    } catch (e) {
      print('Error en el servicio: $e'); // Debug
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> verEvaluacionPorEgresado(
      String egresadoId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/administrativos/evaluaciones/$egresadoId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> listarCarrerasConPDFs() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/administrativo/carreras-con-pdfs'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        print('Error response: ${response.body}'); // Debug
        return {
          'success': false,
          'error': 'Error al obtener carreras con PDFs: ${response.body}',
        };
      }
    } catch (e) {
      print('Exception: $e'); // Debug
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> listarPDFsPorCarrera(String carrera) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/administrativo/pdfs-por-carrera/$carrera'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        print('Error response: ${response.body}'); // Debug
        return {
          'success': false,
          'error': 'Error al obtener PDFs por carrera: ${response.body}',
        };
      }
    } catch (e) {
      print('Exception: $e'); // Debug
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
