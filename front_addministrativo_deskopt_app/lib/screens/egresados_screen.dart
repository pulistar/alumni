import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/administrativo_service.dart';
import '../services/auth_service.dart';

class EgresadosScreen extends StatefulWidget {
  final bool mostrarSoloEvaluaciones;

  const EgresadosScreen({
    super.key,
    this.mostrarSoloEvaluaciones = false,
  });

  @override
  State<EgresadosScreen> createState() => _EgresadosScreenState();
}

class _EgresadosScreenState extends State<EgresadosScreen> {
  final _authService = AuthService();
  final _administrativoService = AdministrativoService();
  final _searchController = TextEditingController();
  final _carreraController = TextEditingController();
  bool? _habilitadoFilter;
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  List<dynamic> _egresados = [];
  int _totalEgresados = 0;
  late bool _mostrarSoloConEvaluacion;

  @override
  void initState() {
    super.initState();
    _mostrarSoloConEvaluacion = widget.mostrarSoloEvaluaciones;
    _cargarEgresados();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _carreraController.dispose();
    super.dispose();
  }

  Future<void> _cargarEgresados() async {
    setState(() => _isLoading = true);

    try {
      final result = _mostrarSoloConEvaluacion
          ? await _administrativoService.listarEgresadosConEvaluacion()
          : await _administrativoService.listarEgresados(
              nombre: _searchController.text,
              carrera: _carreraController.text,
              habilitado: _habilitadoFilter,
              page: _currentPage,
            );

      if (result['success']) {
        final data = result['data'];
        setState(() {
          if (_mostrarSoloConEvaluacion) {
            _egresados = data;
            _totalEgresados = data.length;
            _totalPages = 1;
          } else {
            _egresados = data['egresados'];
            _totalEgresados = data['total'];
            _totalPages = data['totalPaginas'];
          }
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar egresados: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar egresados: $e'),
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

  void _aplicarFiltros() {
    setState(() => _currentPage = 1);
    _cargarEgresados();
  }

  Future<void> _verEvaluacion(String egresadoId) async {
    try {
      final result =
          await _administrativoService.verEvaluacionPorEgresado(egresadoId);

      if (result['success']) {
        final evaluacion = result['data']['evaluacion'];
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Evaluación Profesional'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Egresado: ${evaluacion['Egresado']['nombre']}'),
                    Text('Correo: ${evaluacion['Egresado']['correo']}'),
                    Text('Carrera: ${evaluacion['Egresado']['carrera']}'),
                    const Divider(),
                    Text('Empleo actual: ${evaluacion['empleo_actual']}'),
                    Text(
                        '¿Relacionado con la carrera?: ${evaluacion['relacionado_carrera'] ? 'Sí' : 'No'}'),
                    Text(
                        'Competencias útiles: ${evaluacion['competencias_utiles']}'),
                    Text('Sugerencias: ${evaluacion['sugerencias']}'),
                    Text(
                        'Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(evaluacion['fecha']))}'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar evaluación: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar evaluación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Egresados'),
        actions: [
          IconButton(
            icon: Icon(
              _mostrarSoloConEvaluacion ? Icons.list : Icons.assignment,
              color: _mostrarSoloConEvaluacion ? Colors.blue : null,
            ),
            onPressed: () {
              setState(() {
                _mostrarSoloConEvaluacion = !_mostrarSoloConEvaluacion;
                _currentPage = 1;
              });
              _cargarEgresados();
            },
            tooltip: _mostrarSoloConEvaluacion
                ? 'Mostrar todos los egresados'
                : 'Mostrar solo egresados con evaluación',
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_mostrarSoloConEvaluacion)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Buscar por nombre',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _aplicarFiltros(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _carreraController,
                      decoration: const InputDecoration(
                        labelText: 'Filtrar por carrera',
                        prefixIcon: Icon(Icons.school),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _aplicarFiltros(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<bool?>(
                    value: _habilitadoFilter,
                    hint: const Text('Estado'),
                    items: const [
                      DropdownMenuItem(
                        value: null,
                        child: Text('Todos'),
                      ),
                      DropdownMenuItem(
                        value: true,
                        child: Text('Habilitados'),
                      ),
                      DropdownMenuItem(
                        value: false,
                        child: Text('No habilitados'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _habilitadoFilter = value);
                      _aplicarFiltros();
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _egresados.isEmpty
                    ? const Center(
                        child: Text(
                          'No se encontraron egresados',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _egresados.length,
                        itemBuilder: (context, index) {
                          final egresado = _egresados[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(egresado['nombre']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Correo: ${egresado['correo']}'),
                                  Text('Carrera: ${egresado['carrera']}'),
                                  if (_mostrarSoloConEvaluacion &&
                                      egresado['Evaluacion'] != null)
                                    Text(
                                      'Fecha evaluación: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(egresado['Evaluacion']['fecha']))}',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!_mostrarSoloConEvaluacion)
                                    Chip(
                                      label: Text(
                                        egresado['habilitado']
                                            ? 'Habilitado'
                                            : 'No habilitado',
                                      ),
                                      backgroundColor: egresado['habilitado']
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.red.withOpacity(0.2),
                                    ),
                                  if (_mostrarSoloConEvaluacion)
                                    IconButton(
                                      icon: const Icon(Icons.visibility),
                                      onPressed: () =>
                                          _verEvaluacion(egresado['id']),
                                      tooltip: 'Ver evaluación',
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          if (!_isLoading &&
              _egresados.isNotEmpty &&
              !_mostrarSoloConEvaluacion)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 1
                        ? () {
                            setState(() => _currentPage--);
                            _cargarEgresados();
                          }
                        : null,
                  ),
                  Text(
                    'Página $_currentPage de $_totalPages',
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < _totalPages
                        ? () {
                            setState(() => _currentPage++);
                            _cargarEgresados();
                          }
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
