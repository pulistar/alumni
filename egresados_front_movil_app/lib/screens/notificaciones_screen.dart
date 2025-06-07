import 'package:flutter/material.dart';

import '../services/notificacion_service.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  final NotificacionService _notificacionService = NotificacionService();
  List<Map<String, dynamic>> _notificaciones = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    setState(() => _cargando = true);
    try {
      final notificaciones = await _notificacionService.obtenerNotificaciones();
      setState(() {
        _notificaciones = notificaciones;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar notificaciones')),
        );
      }
    }
  }

  Future<void> _marcarComoLeida(String id) async {
    try {
      final exito = await _notificacionService.marcarComoLeida(id);
      if (exito) {
        setState(() {
          final index = _notificaciones.indexWhere((n) => n['id'] == id);
          if (index != -1) {
            _notificaciones[index]['leida'] = true;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al marcar notificación como leída'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body:
          _cargando
              ? const Center(child: CircularProgressIndicator())
              : _notificaciones.isEmpty
              ? const Center(child: Text('No hay notificaciones'))
              : RefreshIndicator(
                onRefresh: _cargarNotificaciones,
                child: ListView.builder(
                  itemCount: _notificaciones.length,
                  itemBuilder: (context, index) {
                    final notificacion = _notificaciones[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: Icon(
                          notificacion['leida']
                              ? Icons.mark_email_read
                              : Icons.mark_email_unread,
                          color:
                              notificacion['leida']
                                  ? Colors.grey
                                  : Theme.of(context).primaryColor,
                        ),
                        title: Text(
                          notificacion['titulo'],
                          style: TextStyle(
                            fontWeight:
                                notificacion['leida']
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notificacion['mensaje']),
                            const SizedBox(height: 4),
                            Text(
                              'Enviado: ${DateTime.parse(notificacion['fecha_envio']).toString().split('.')[0]}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _marcarComoLeida(notificacion['id']),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
