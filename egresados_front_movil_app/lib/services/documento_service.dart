import 'dart:convert';
import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DocumentoService {
  final String baseUrl =
      'https://34c1-161-18-63-163.ngrok-free.app/api/egresados';
  final cloudinary = CloudinaryPublic(
    dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'dhkbaumfo',
    dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'flutter_unsigned',
  );
  final http.Client _client = http.Client();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<bool> verificarDocumentosSubidos() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await _client.get(
        Uri.parse('$baseUrl/perfil'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['documentos_subidos'] ?? false;
      } else {
        throw Exception('Error al verificar documentos: ${response.body}');
      }
    } catch (e) {
      print('Error al verificar documentos subidos: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> subirDocumentos({
    required File encuesta2,
    required File bolsaEmpleo,
    required File momentoOle,
  }) async {
    try {
      print('Iniciando subida de documentos a Cloudinary...');

      // Subir todos los documentos a Cloudinary
      final encuesta2Response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          encuesta2.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'documentos_egresados',
        ),
      );

      final bolsaEmpleoResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          bolsaEmpleo.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'documentos_egresados',
        ),
      );

      final momentoOleResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          momentoOle.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'documentos_egresados',
        ),
      );

      print('Documentos subidos a Cloudinary exitosamente');

      // Obtener token
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'No hay sesión activa'};
      }

      // Enviar todas las URLs al backend
      print('Enviando URLs al backend...');
      final response = await _client.post(
        Uri.parse('$baseUrl/documentos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'documentos': [
            {'tipo': 'encuesta2', 'url': encuesta2Response.secureUrl},
            {'tipo': 'bolsa_empleo', 'url': bolsaEmpleoResponse.secureUrl},
            {'tipo': 'momento_ole', 'url': momentoOleResponse.secureUrl},
          ],
        }),
      );

      print('Respuesta del backend - Status: ${response.statusCode}');
      print('Respuesta del backend - Body: ${response.body}');

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Documentos subidos exitosamente'};
      } else {
        return {
          'success': false,
          'message':
              'Error al registrar documentos en el backend: ${response.body}',
        };
      }
    } catch (e) {
      print('Error en subirDocumentos: $e');
      return {'success': false, 'message': 'Error al subir documentos: $e'};
    }
  }

  Future<List<Map<String, dynamic>>> listarDocumentos() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await _client.get(
        Uri.parse('$baseUrl/documentos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> documentos = json.decode(response.body);
        return documentos.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener documentos: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al listar documentos: $e');
    }
  }

  Future<bool> eliminarDocumento(String documentoId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await _client.delete(
        Uri.parse('$baseUrl/documentos/$documentoId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error al eliminar documento: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al eliminar documento: $e');
    }
  }

  Future<Map<String, dynamic>> subirDocumento({
    required File archivo,
    required String tipo,
  }) async {
    try {
      // Obtener token
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'No hay sesión activa'};
      }

      // Subir a Cloudinary
      final cloudinaryResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          archivo.path,
          resourceType:
              tipo == 'Momento OLE'
                  ? CloudinaryResourceType.Raw
                  : CloudinaryResourceType.Image,
          folder: 'documentos_egresados',
        ),
      );

      // Enviar URL al backend
      final response = await _client.post(
        Uri.parse('$baseUrl/documentos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'documentos': [
            {
              'tipo': tipo.toLowerCase().replaceAll(' ', '_'),
              'url': cloudinaryResponse.secureUrl,
            },
          ],
        }),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Documento subido exitosamente',
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Error al subir documento: ${response.body}',
        };
      }
    } catch (e) {
      print('Error al subir documento: $e');
      return {'success': false, 'message': 'Error al subir documento: $e'};
    }
  }

  void dispose() {
    _client.close();
  }
}
