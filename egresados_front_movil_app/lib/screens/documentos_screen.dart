import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/documento_service.dart';

class DocumentosScreen extends StatefulWidget {
  const DocumentosScreen({super.key});

  @override
  State<DocumentosScreen> createState() => _DocumentosScreenState();
}

class _DocumentosScreenState extends State<DocumentosScreen> {
  final DocumentoService _documentoService = DocumentoService();
  bool _isLoading = false;
  bool _documentosSubidos = false;
  List<Map<String, dynamic>> _documentos = [];

  @override
  void initState() {
    super.initState();
    _cargarDocumentos();
    _verificarDocumentosSubidos();
  }

  Future<void> _verificarDocumentosSubidos() async {
    try {
      final subidos = await _documentoService.verificarDocumentosSubidos();
      if (mounted) {
        setState(() {
          _documentosSubidos = subidos;
        });
      }
    } catch (e) {
      print('Error al verificar documentos subidos: $e');
    }
  }

  Future<void> _cargarDocumentos() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final documentos = await _documentoService.listarDocumentos();
      if (mounted) {
        setState(() {
          _documentos = documentos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _mostrarMensaje(e.toString(), esError: true);
      }
    }
  }

  Future<void> _subirDocumentos() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Obtener los archivos
      final encuesta2 = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (encuesta2 == null) {
        _mostrarMensaje(
          'Debes seleccionar la encuesta de seguimiento',
          esError: true,
        );
        return;
      }

      final bolsaEmpleo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (bolsaEmpleo == null) {
        _mostrarMensaje(
          'Debes seleccionar la encuesta de bolsa de empleo',
          esError: true,
        );
        return;
      }

      final momentoOle = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (momentoOle == null) {
        _mostrarMensaje('Debes seleccionar el momento OLE', esError: true);
        return;
      }

      // Subir todos los documentos
      final resultado = await _documentoService.subirDocumentos(
        encuesta2: File(encuesta2.path),
        bolsaEmpleo: File(bolsaEmpleo.path),
        momentoOle: File(momentoOle.path),
      );

      if (resultado['success']) {
        _mostrarMensaje('Documentos subidos exitosamente');
        await _cargarDocumentos();
        await _verificarDocumentosSubidos();
      } else {
        _mostrarMensaje(resultado['message'], esError: true);
      }
    } catch (e) {
      _mostrarMensaje('Error al subir documentos: $e', esError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _eliminarDocumento(String id) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final eliminado = await _documentoService.eliminarDocumento(id);
      if (mounted) {
        setState(() => _isLoading = false);
        if (eliminado) {
          _mostrarMensaje('Documento eliminado exitosamente');
          _cargarDocumentos();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _mostrarMensaje(e.toString(), esError: true);
      }
    }
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Documentos'),
        backgroundColor: Colors.blue,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  if (_documentosSubidos)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '¡Felicidades! Has completado todos los documentos requeridos.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Navegar a la pantalla de evaluación
                              Navigator.pushNamed(context, '/evaluacion');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Ir a Evaluación'),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child:
                        _documentos.isEmpty
                            ? const Center(
                              child: Text(
                                'No hay documentos subidos',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                            : ListView.builder(
                              itemCount: _documentos.length,
                              itemBuilder: (context, index) {
                                final doc = _documentos[index];
                                return Card(
                                  margin: const EdgeInsets.all(8),
                                  child: ListTile(
                                    title: Text(doc['tipo'] ?? 'Sin tipo'),
                                    subtitle: Text(
                                      'Subido: ${doc['fecha_subida'] ?? 'Fecha desconocida'}',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () => _eliminarDocumento(
                                            doc['id'].toString(),
                                          ),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
      floatingActionButton:
          !_documentosSubidos
              ? FloatingActionButton(
                onPressed: _subirDocumentos,
                child: const Icon(Icons.upload_file),
              )
              : null,
    );
  }

  @override
  void dispose() {
    _documentoService.dispose();
    super.dispose();
  }
}
