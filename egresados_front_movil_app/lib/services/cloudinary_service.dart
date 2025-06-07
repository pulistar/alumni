import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String _cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  final String _uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  /// Sube un archivo a Cloudinary y devuelve la URL pública si fue exitoso, o null si falló.
  Future<String?> uploadFile(
    File file, {
    required String folder,
    required String egresadoId,
    required String publicId,
  }) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = folder
      ..fields['public_id'] = publicId
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['secure_url'];
    } else {
      print('Error subida Cloudinary: ${response.body}');
      return null;
    }
  }
}
