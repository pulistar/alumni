import 'package:flutter/material.dart';

import '../services/PerfilService.dart'; // Asegúrate de que la ruta es correcta

class EstadoHabilitacionWidget extends StatefulWidget {
  @override
  _EstadoHabilitacionWidgetState createState() => _EstadoHabilitacionWidgetState();
}

class _EstadoHabilitacionWidgetState extends State<EstadoHabilitacionWidget> {
  bool? habilitado;
  bool cargando = true;
  String? error;

  @override
  void initState() {
    super.initState();
    verificarHabilitacion();
  }

  Future<void> verificarHabilitacion() async {
    final servicio = PerfilService();
    final resultado = await servicio.obtenerEstadoHabilitacion();

    setState(() {
      habilitado = resultado;
      cargando = false;
      if (resultado == null) {
        error = "No se pudo obtener el estado de habilitación";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return Scaffold(
        appBar: AppBar(title: Text('Validación')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Validación')),
        body: Center(child: Text(error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Estado de Habilitación')),
      body: Center(
        child: Text(
          habilitado == true
              ? 'Tu cuenta ha sido habilitada por el área Alumni.'
              : 'Tu cuenta está pendiente de validación por el área Alumni.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
