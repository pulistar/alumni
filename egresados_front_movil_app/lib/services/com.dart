import 'dart:convert';

import 'package:http/http.dart' as http;

class Documento {
  final int id;
  final String tipo;
  final String url;

  Documento({required this.id, required this.tipo, required this.url});

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(id: json['id'], tipo: json['tipo'], url: json['url']);
  }
}

class ProgresoDocumentos {
  final int totalRequeridos;
  final int subidos;
  final bool completado;
  final List<String> faltantes;

  ProgresoDocumentos({
    required this.totalRequeridos,
    required this.subidos,
    required this.completado,
    required this.faltantes,
  });

  factory ProgresoDocumentos.fromJson(Map<String, dynamic> json) {
    return ProgresoDocumentos(
      totalRequeridos: json['totalRequeridos'],
      subidos: json['subidos'],
      completado: json['completado'],
      faltantes: List<String>.from(json['faltantes']),
    );
  }
}

class SubirDocumentosService {
  final String baseUrl =
      'https://34c1-161-18-63-163.ngrok-free.app/api/egresados';
  final Map<String, String> headers;

  SubirDocumentosService({required this.headers});

  Future<List<Documento>> obtenerDocumentos() async {
    final res = await http.get(
      Uri.parse('$baseUrl/documentos'),
      headers: headers,
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body)['documentos'];
      return data.map((doc) => Documento.fromJson(doc)).toList();
    } else {
      throw Exception('Error al obtener documentos');
    }
  }

  Future<bool> subirDocumento(String tipo, String url) async {
    final res = await http.post(
      Uri.parse('$baseUrl/documentos'),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'tipo': tipo, 'url': url}),
    );

    return res.statusCode == 201;
  }

  Future<bool> eliminarDocumento(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/documentos/$id'),
      headers: headers,
    );

    return res.statusCode == 200;
  }

  Future<ProgresoDocumentos> obtenerProgreso() async {
    final res = await http.get(
      Uri.parse('$baseUrl/documentos/progreso'),
      headers: headers,
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return ProgresoDocumentos.fromJson(data);
    } else {
      throw Exception('Error al consultar progreso');
    }
  }
}
