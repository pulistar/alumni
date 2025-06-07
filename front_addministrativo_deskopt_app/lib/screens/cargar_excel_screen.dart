import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../services/administrativo_service.dart';

class CargarExcelScreen extends StatefulWidget {
  const CargarExcelScreen({super.key});

  @override
  State<CargarExcelScreen> createState() => _CargarExcelScreenState();
}

class _CargarExcelScreenState extends State<CargarExcelScreen> {
  final _administrativoService = AdministrativoService();
  bool _isUploading = false;
  File? _selectedFile;

  Future<void> _seleccionarArchivo() async {
    try {
      final typeGroup = XTypeGroup(
        label: 'Excel',
        extensions: ['xlsx', 'xls'],
      );

      final file = await openFile(acceptedTypeGroups: [typeGroup]);

      if (file == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se seleccionó ningún archivo'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final filePath = file.path;
      if (filePath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al obtener la ruta del archivo'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final fileObj = File(filePath);
      if (!await fileObj.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El archivo no existe'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedFile = fileObj;
      });
    } catch (e) {
      print('Error al seleccionar archivo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al seleccionar el archivo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _subirExcel() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione un archivo primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      setState(() => _isUploading = true);

      final result =
          await _administrativoService.subirExcelEgresados(_selectedFile!);

      if (result['success']) {
        final responseData = json.decode(result['data']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseData['noEncontrados']?.isNotEmpty == true
                    ? 'Proceso completado. Algunos correos no fueron encontrados: ${responseData['noEncontrados'].join(', ')}'
                    : 'Excel procesado correctamente',
              ),
              backgroundColor: responseData['noEncontrados']?.isNotEmpty == true
                  ? Colors.orange
                  : Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al procesar el Excel: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error al subir Excel: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al subir el archivo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cargar Excel de Egresados'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.upload_file,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Formato del Excel',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'El archivo Excel debe contener las siguientes columnas:\n\n'
                '1. correo (debe terminar en @campusucc.edu.co)\n\n'
                'El sistema habilitará automáticamente los egresados cuyos correos coincidan con los del Excel.',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
            if (_selectedFile != null) ...[
              Text(
                'Archivo seleccionado: ${path.basename(_selectedFile!.path)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _seleccionarArchivo,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Seleccionar Excel'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _isUploading || _selectedFile == null
                      ? null
                      : _subirExcel,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.upload_file),
                  label: Text(_isUploading ? 'Subiendo...' : 'Subir Excel'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
