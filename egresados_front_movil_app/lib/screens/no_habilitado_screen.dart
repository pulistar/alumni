import 'package:flutter/material.dart';

import '../services/PerfilService.dart';

class NoHabilitadoScreen extends StatefulWidget {
  const NoHabilitadoScreen({super.key});

  @override
  State<NoHabilitadoScreen> createState() => _NoHabilitadoScreenState();
}

class _NoHabilitadoScreenState extends State<NoHabilitadoScreen> {
  bool _loading = false;

  Future<void> _verificarEstado() async {
    setState(() => _loading = true);

    final perfilService = PerfilService();
    final estado = await perfilService.obtenerEstadoHabilitacion();

    setState(() => _loading = false);

    if (estado == true) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aún no estás habilitado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¡Bienvenido Alumni!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ten paciencia, pronto será tu turno de seguir adelante.',
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _verificarEstado,
                      icon: const Icon(Icons.refresh),
                      label: const Text(
                        'Volver a intentar',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
