import 'package:flutter/material.dart';

import '../services/notificacion_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotificacionService _notificacionService = NotificacionService();
  int _notificacionesNoLeidas = 0;

  @override
  void initState() {
    super.initState();
    _cargarNotificacionesNoLeidas();
  }

  Future<void> _cargarNotificacionesNoLeidas() async {
    final count = await _notificacionService.obtenerNotificacionesNoLeidas();
    if (mounted) {
      setState(() {
        _notificacionesNoLeidas = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade700;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alumni',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 8,
        shadowColor: Colors.black54,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/notificaciones');
                  _cargarNotificacionesNoLeidas();
                },
              ),
              if (_notificacionesNoLeidas > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_notificacionesNoLeidas',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildButton(
                context,
                icon: Icons.school_outlined,
                label: 'Proceso de grado',
                color: primaryColor,
                onPressed: () {
                  Navigator.pushNamed(context, '/subir-documentos');
                },
              ),
              const SizedBox(height: 30),
              _buildButton(
                context,
                icon: Icons.assignment_outlined,
                label: 'Evaluación',
                color: primaryColor,
                onPressed: () {
                  Navigator.pushNamed(context, '/evaluacion');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 28, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shadowColor: Colors.black45,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          animationDuration: const Duration(milliseconds: 250),
        ),
      ),
    );
  }
}
