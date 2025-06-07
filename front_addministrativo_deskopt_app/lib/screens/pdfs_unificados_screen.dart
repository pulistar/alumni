import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../services/administrativo_service.dart';
import '../services/auth_service.dart';

class PDFsUnificadosScreen extends StatefulWidget {
  const PDFsUnificadosScreen({super.key});

  @override
  State<PDFsUnificadosScreen> createState() => _PDFsUnificadosScreenState();
}

class _PDFsUnificadosScreenState extends State<PDFsUnificadosScreen> {
  final AdministrativoService _administrativoService = AdministrativoService();
  bool _isLoading = false;
  List<String> _carreras = [];
  String? _carreraSeleccionada;
  List<Map<String, dynamic>> _pdfs = [];

  @override
  void initState() {
    super.initState();
    _cargarCarreras();
  }

  Future<void> _cargarCarreras() async {
    setState(() => _isLoading = true);
    try {
      final result = await _administrativoService.listarCarrerasConPDFs();
      if (result['success']) {
        setState(() {
          _carreras = List<String>.from(result['data']);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar carreras: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar carreras: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cargarPDFsPorCarrera(String carrera) async {
    setState(() {
      _isLoading = true;
      _carreraSeleccionada = carrera;
    });

    try {
      final result = await _administrativoService.listarPDFsPorCarrera(carrera);
      if (result['success']) {
        setState(() {
          _pdfs = List<Map<String, dynamic>>.from(result['data']);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar PDFs: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar PDFs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _descargarPDF(int egresadoId, String nombre) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/api/administrativo/pdf-unificado/$egresadoId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final saveLocation = await getSaveLocation(
          suggestedName: 'documentos_$nombre.pdf',
        );

        if (saveLocation != null) {
          final file = File(saveLocation.path);
          await file.writeAsBytes(response.bodyBytes);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF guardado en: ${saveLocation.path}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        print('Error response: ${response.body}'); // Debug
        final error = json.decode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error['message'] ?? 'Error al descargar el PDF'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Exception: $e'); // Debug
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar el PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _getToken() async {
    try {
      final authService = AuthService();
      return await authService.getToken();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener el token: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDFs Unificados'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Seleccionar Carrera',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    value: _carreraSeleccionada,
                    items: _carreras.map((carrera) {
                      return DropdownMenuItem(
                        value: carrera,
                        child: Text(carrera),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _cargarPDFsPorCarrera(value);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: _pdfs.isEmpty
                      ? Center(
                          child: Text(
                            _carreraSeleccionada == null
                                ? 'Seleccione una carrera'
                                : 'No hay PDFs disponibles para esta carrera',
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _pdfs.length,
                          itemBuilder: (context, index) {
                            final pdf = _pdfs[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.red,
                                  size: 32,
                                ),
                                title: Text(pdf['nombre']),
                                subtitle: Text(pdf['correo']),
                                trailing: IconButton(
                                  icon: const Icon(Icons.download),
                                  onPressed: () => _descargarPDF(
                                    pdf['id'],
                                    pdf['nombre'],
                                  ),
                                  tooltip: 'Descargar PDF',
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
