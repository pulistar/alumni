import 'package:flutter/material.dart';

import '../services/evaluacion_service.dart';

class EvaluacionScreen extends StatefulWidget {
  const EvaluacionScreen({super.key});

  @override
  State<EvaluacionScreen> createState() => _EvaluacionScreenState();
}

class _EvaluacionScreenState extends State<EvaluacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final EvaluacionService _evaluacionService = EvaluacionService();

  final TextEditingController _empleoController = TextEditingController();
  bool _relacionadoCarrera = false;
  List<String> _competenciasUtiles = [];
  final TextEditingController _sugerenciasController = TextEditingController();

  bool _loading = false;

  final List<String> _competenciasOpciones = [
    'Trabajo en equipo',
    'Comunicación',
    'Liderazgo',
    'Adaptabilidad',
    'Resolución de problemas',
    'Conocimientos técnicos',
  ];

  Map<String, bool> _competenciasSeleccionadas = {};

  @override
  void initState() {
    super.initState();
    for (var comp in _competenciasOpciones) {
      _competenciasSeleccionadas[comp] = false;
    }
  }

  @override
  void dispose() {
    _empleoController.dispose();
    _sugerenciasController.dispose();
    super.dispose();
  }

  void _enviarEvaluacion() async {
    if (!_formKey.currentState!.validate()) return;

    _competenciasUtiles = _competenciasSeleccionadas.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (_competenciasUtiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una competencia útil')),
      );
      return;
    }

    setState(() => _loading = true);

    final result = await _evaluacionService.enviarEvaluacion(
      empleoActual: _empleoController.text.trim(),
      relacionadoCarrera: _relacionadoCarrera,
      competenciasUtiles: _competenciasUtiles,
      sugerencias: _sugerenciasController.text.trim(),
    );

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Error inesperado')),
    );

    if (result['ok'] == true) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade700;
    final secondaryColor = Colors.blue.shade300;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluación Profesional'),
        backgroundColor: primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [secondaryColor.withOpacity(0.6), primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Por favor completa la evaluación profesional',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _empleoController,
                    decoration: InputDecoration(
                      labelText: 'Empleo actual',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.work),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa tu empleo actual';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Checkbox(
                        value: _relacionadoCarrera,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _relacionadoCarrera = value;
                            });
                          }
                        },
                        activeColor: primaryColor,
                      ),
                      Expanded(
                        child: Text(
                          '¿Tu empleo está relacionado con tu carrera?',
                          style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Competencias útiles en tu empleo:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  ..._competenciasOpciones.map((comp) {
                    return CheckboxListTile(
                      title: Text(comp),
                      value: _competenciasSeleccionadas[comp],
                      activeColor: primaryColor,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (value) {
                        setState(() {
                          _competenciasSeleccionadas[comp] = value ?? false;
                        });
                      },
                    );
                  }).toList(),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _sugerenciasController,
                    decoration: InputDecoration(
                      labelText: 'Sugerencias (opcional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.feedback_outlined),
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 28),

                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _enviarEvaluacion,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                            shadowColor: Colors.black38,
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('Enviar Evaluación'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
