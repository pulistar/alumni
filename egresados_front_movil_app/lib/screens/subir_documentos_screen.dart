import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/documento_service.dart';

class SubirDocumentosScreen extends StatefulWidget {
  const SubirDocumentosScreen({super.key});

  @override
  State<SubirDocumentosScreen> createState() => _SubirDocumentosScreenState();
}

class _SubirDocumentosScreenState extends State<SubirDocumentosScreen> {
  final DocumentoService _documentoService = DocumentoService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _documentos = [];

  @override
  void initState() {
    super.initState();
    _cargarDocumentos();
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

  Future<void> _verDocumento(String url, String tipo) async {
    try {
      if (tipo.toLowerCase().contains('pdf')) {
        // Descargar y mostrar el PDF
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/documento.pdf');

        // Descargar el archivo
        await Dio().download(url, file.path);

        if (!mounted) return;

        // Mostrar el PDF
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text(tipo),
                backgroundColor: Colors.blue,
              ),
              body: PDFView(
                filePath: file.path,
                enableSwipe: true,
                swipeHorizontal: false,
                autoSpacing: true,
                pageFling: true,
                pageSnap: true,
                fitPolicy: FitPolicy.BOTH,
                preventLinkNavigation: false,
              ),
            ),
          ),
        );
      } else {
        // Mostrar imagen usando PhotoView
        _mostrarImagen(url, tipo);
      }
    } catch (e) {
      print('Error al abrir documento: $e');
      _mostrarMensaje('Error al abrir el documento: $e', esError: true);
    }
  }

  void _mostrarImagen(String url, String tipo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(tipo),
            backgroundColor: Colors.blue,
          ),
          body: PhotoView(
            imageProvider: NetworkImage(url),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _abrirEnlace(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalNonBrowserApplication,
        );
      } else {
        // Si no se puede abrir con la aplicación externa, intentar con el navegador
        await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
        );
      }
    } catch (e) {
      print('Error al abrir enlace: $e');
      _mostrarMensaje('Error al abrir el enlace: $e', esError: true);
    }
  }

  Future<void> _subirDocumento(String tipo) async {
    try {
      setState(() => _isLoading = true);

      // Obtener el archivo según el tipo
      final archivo = tipo == 'Momento OLE'
          ? await ImagePicker().pickMedia() // Permite seleccionar PDF
          : await ImagePicker().pickImage(
              source: ImageSource.gallery,
              imageQuality: 80, // Comprimir la imagen para mejor rendimiento
            );

      if (archivo == null) {
        _mostrarMensaje('Debes seleccionar un archivo', esError: true);
        return;
      }

      // Mapear el tipo de documento al formato esperado por el backend
      String tipoDocumento;
      switch (tipo) {
        case 'Momento OLE':
          tipoDocumento = 'momento_ole';
          break;
        case 'Actualización Datos Egresados':
          tipoDocumento = 'encuesta2';
          break;
        case 'Bolsa de Empleo':
          tipoDocumento = 'bolsa_empleo';
          break;
        default:
          tipoDocumento = tipo.toLowerCase().replaceAll(' ', '_');
      }

      final resultado = await _documentoService.subirDocumento(
        archivo: File(archivo.path),
        tipo: tipoDocumento,
      );

      if (resultado['success']) {
        _mostrarMensaje('Documento subido exitosamente');
        await _cargarDocumentos();
      } else {
        _mostrarMensaje(resultado['message'], esError: true);
      }
    } catch (e) {
      _mostrarMensaje('Error al subir documento: $e', esError: true);
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

  Widget _buildRequisitoCard(
      String titulo, String descripcion, String url, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(descripcion),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _abrirEnlace(url),
                    icon: const Icon(Icons.link),
                    label: const Text('Abrir Encuesta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _subirDocumento(titulo),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Subir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requisitos de Grado'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarDocumentos,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.blue.shade50,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recomendaciones Importantes:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                              '• Registrar en las encuestas su correo personal, NO el de campus.'),
                          Text(
                              '• En la Encuesta #2 Diligenciar EN MAYÚSCULAS SOSTENIDA.'),
                          Text(
                              '• La fotografía en la hoja de vida debe ser formal y ejecutiva.'),
                          Text(
                              '• Asegúrese de completar todos los campos al 100%.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRequisitoCard(
                      'Momento OLE',
                      'Descargar la constancia en PDF para anexar en el archivo con los demás soportes.\nNOTA: No aplica para Técnico en Auxiliar de enfermería ni Posgrados.',
                      'https://encuestasole.mineducacion.gov.co/hecaa-encuestas/login_encuestas',
                      Icons.school,
                    ),
                    _buildRequisitoCard(
                      'Actualización Datos Egresados',
                      'Tomar pantallazo al finalizar la encuesta.',
                      'https://forms.office.com/Pages/ResponsePage.aspx?id=BMPJbvsR70Kmr1tflzw5Zp3FVe__lW9PtwpTxEj390pUMk8xUU0wODVCVUMwUzVTNVFIVlVYVE1OSC4u',
                      Icons.person,
                    ),
                    _buildRequisitoCard(
                      'Bolsa de Empleo',
                      'Tomar pantallazo al finalizar el registro.\nUsuario: Correo electrónico personal\nContraseña: Número de Cédula',
                      'https://www.elempleo.com/co/sitio-empresarial/universidad-cooperativa-colombia',
                      Icons.work,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.orange.shade50,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Importante!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Si no puede ingresar a la plataforma, acérquese a la oficina de Egresados e Internacionalización (2do piso) o envíe un correo a:',
                          ),
                          Text('claudia.gomezt@ucc.edu.co'),
                          Text('con copia a:'),
                          Text('yessica.munozr@ucc.edu.co'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_documentos.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Documentos Subidos:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _documentos.length,
                        itemBuilder: (context, index) {
                          final doc = _documentos[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: Icon(
                                doc['tipo']
                                        .toString()
                                        .toLowerCase()
                                        .contains('pdf')
                                    ? Icons.picture_as_pdf
                                    : Icons.image,
                                color: Colors.blue,
                              ),
                              title: Text(doc['tipo'] ?? 'Sin tipo'),
                              subtitle: Text(
                                'Subido: ${doc['fecha_subida'] ?? 'Fecha desconocida'}',
                              ),
                              onTap: () =>
                                  _verDocumento(doc['url'], doc['tipo']),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        _verDocumento(doc['url'], doc['tipo']),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _eliminarDocumento(
                                        doc['id'].toString()),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _documentoService.dispose();
    super.dispose();
  }
}
