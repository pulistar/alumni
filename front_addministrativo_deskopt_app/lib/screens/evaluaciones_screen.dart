import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../services/administrativo_service.dart';

class EvaluacionesScreen extends StatefulWidget {
  const EvaluacionesScreen({super.key});

  @override
  State<EvaluacionesScreen> createState() => _EvaluacionesScreenState();
}

class _EvaluacionesScreenState extends State<EvaluacionesScreen> {
  final _administrativoService = AdministrativoService();
  bool _isLoading = false;
  List<dynamic> _evaluaciones = [];
  bool _mostrarGraficas = false;

  @override
  void initState() {
    super.initState();
    _cargarEvaluaciones();
  }

  Future<void> _cargarEvaluaciones() async {
    setState(() => _isLoading = true);

    try {
      final result =
          await _administrativoService.listarEgresadosConEvaluacion();
      print('Resultado del backend: $result'); // Debug

      if (result['success']) {
        final data = result['data'];
        print('Datos recibidos: $data'); // Debug
        setState(() {
          _evaluaciones = data;
        });
        print('Evaluaciones cargadas: ${_evaluaciones.length}'); // Debug
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar evaluaciones: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error al cargar evaluaciones: $e'); // Debug
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar evaluaciones: $e'),
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

  void _verEvaluacion(Map<String, dynamic> evaluacion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Evaluación de ${evaluacion['nombre']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Email: ${evaluacion['correo']}'),
              Text('Carrera: ${evaluacion['carrera']}'),
              const SizedBox(height: 16),
              Text(
                  'Empleo actual: ${evaluacion['evaluacion']['empleo_actual'] ?? 'No especificado'}'),
              Text(
                  '¿Relacionado con la carrera?: ${evaluacion['evaluacion']['relacionado_carrera'] ? 'Sí' : 'No'}'),
              const SizedBox(height: 8),
              const Text('Competencias útiles:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              if (evaluacion['evaluacion']['competencias_utiles'] != null)
                ...(evaluacion['evaluacion']['competencias_utiles'] as List)
                    .map((comp) => Text('• $comp')),
              const SizedBox(height: 8),
              const Text('Sugerencias:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                  evaluacion['evaluacion']['sugerencias'] ?? 'Sin sugerencias'),
              const SizedBox(height: 8),
              Text(
                'Fecha: ${evaluacion['evaluacion']['fecha'] != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(evaluacion['evaluacion']['fecha'])) : 'No especificada'}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
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

  Map<String, int> _calcularEstadisticasCarreras() {
    final estadisticas = <String, int>{};
    for (var evaluacion in _evaluaciones) {
      final carrera = evaluacion['carrera'];
      estadisticas[carrera] = (estadisticas[carrera] ?? 0) + 1;
    }
    return estadisticas;
  }

  Map<String, int> _calcularEstadisticasEmpleo() {
    final estadisticas = <String, int>{};
    for (var evaluacion in _evaluaciones) {
      final relacionado =
          evaluacion['evaluacion']['relacionado_carrera'] ? 'Sí' : 'No';
      estadisticas[relacionado] = (estadisticas[relacionado] ?? 0) + 1;
    }
    return estadisticas;
  }

  List<String> _obtenerCompetenciasMasFrecuentes() {
    final competencias = <String, int>{};
    for (var evaluacion in _evaluaciones) {
      final listaCompetencias =
          evaluacion['evaluacion']['competencias_utiles'] as List?;
      if (listaCompetencias != null) {
        for (var competencia in listaCompetencias) {
          competencias[competencia] = (competencias[competencia] ?? 0) + 1;
        }
      }
    }
    final competenciasOrdenadas = competencias.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return competenciasOrdenadas.take(5).map((e) => e.key).toList();
  }

  Widget _construirGraficaCarreras() {
    final estadisticas = _calcularEstadisticasCarreras();
    final List<Color> colores = [
      const Color(0xFF6B8DE3), // Azul suave
      const Color(0xFF7C4DFF), // Púrpura
      const Color(0xFF43A047), // Verde
      const Color(0xFFFFB300), // Ámbar
      const Color(0xFFE53935), // Rojo
      const Color(0xFF00ACC1), // Cian
      const Color(0xFF8E24AA), // Púrpura oscuro
    ];

    final data = estadisticas.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final e = entry.value;
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '${e.key}\n${e.value}',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        color: colores[index % colores.length],
        badgeWidget: _Badge(
          '${e.key}\n${e.value}',
          size: 40,
          borderColor: colores[index % colores.length],
        ),
        badgePositionPercentageOffset: 1.1,
      );
    }).toList();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.blue.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.pie_chart,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Distribución por Carrera',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Row(
                            children: [
                              Icon(Icons.pie_chart,
                                  color: Colors.blue.shade400),
                              const SizedBox(width: 8),
                              const Text('Distribución por Carrera'),
                            ],
                          ),
                          content: const Text(
                            'Este gráfico muestra la distribución de evaluaciones por carrera profesional. '
                            'Cada sección representa una carrera y muestra el número de evaluaciones recibidas.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Entendido'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sections: data,
                        sectionsSpace: 2,
                        centerSpaceRadius: 60,
                        startDegreeOffset: -90,
                        centerSpaceColor: Colors.white,
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            // Manejar interacción táctil
                          },
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                Text(
                                  '${estadisticas.values.fold(0, (a, b) => a + b)}',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    estadisticas.entries.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final e = entry.value;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colores[index % colores.length].withOpacity(0.1),
                          colores[index % colores.length].withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colores[index % colores.length],
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              colores[index % colores.length].withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colores[index % colores.length],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colores[index % colores.length]
                                    .withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${e.key}: ${e.value}',
                          style: TextStyle(
                            color: colores[index % colores.length],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirGraficaEmpleo() {
    final estadisticas = _calcularEstadisticasEmpleo();
    final data = estadisticas.entries
        .map((e) => BarChartGroupData(
              x: e.key == 'Sí' ? 0 : 1,
              barRods: [
                BarChartRodData(
                  toY: e.value.toDouble(),
                  color: e.key == 'Sí'
                      ? const Color(0xFF43A047)
                      : const Color(0xFFE53935),
                  width: 40,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: estadisticas.values
                        .reduce((a, b) => a > b ? a : b)
                        .toDouble(),
                    color: Colors.grey.shade200,
                  ),
                ),
              ],
            ))
        .toList();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.green.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.bar_chart,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Empleo Relacionado',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Row(
                            children: [
                              Icon(Icons.bar_chart,
                                  color: Colors.green.shade400),
                              const SizedBox(width: 8),
                              const Text('Empleo Relacionado'),
                            ],
                          ),
                          content: const Text(
                            'Este gráfico muestra cuántos egresados tienen empleo relacionado con su carrera. '
                            'La barra verde representa "Sí" y la roja representa "No".',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Entendido'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: estadisticas.values
                            .reduce((a, b) => a > b ? a : b)
                            .toDouble() +
                        1,
                    barGroups: data,
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                value == 0 ? 'Sí' : 'No',
                                style: const TextStyle(
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade300,
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                        left: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Sí', const Color(0xFF43A047)),
                  const SizedBox(width: 24),
                  _buildLegendItem('No', const Color(0xFFE53935)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCompetenciasFrecuentes() {
    final competencias = _obtenerCompetenciasMasFrecuentes();
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.amber.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Competencias Destacadas',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber.shade400),
                              const SizedBox(width: 8),
                              const Text('Competencias Destacadas'),
                            ],
                          ),
                          content: const Text(
                            'Esta lista muestra las 5 competencias más mencionadas por los egresados '
                            'como útiles para su desarrollo profesional.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Entendido'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...competencias.toList().asMap().entries.map((entry) {
                final index = entry.key;
                final competencia = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade50,
                        Colors.amber.shade100.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.amber.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade100,
                              Colors.amber.shade200,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          competencia,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.star,
                          color: Colors.amber.shade700,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportarPDF() async {
    try {
      setState(() => _isLoading = true);

      // Crear el PDF
      final pdf = pw.Document();
      final now = DateTime.now();
      final fecha = DateFormat('yyyyMMdd').format(now);
      final hora = DateFormat('HHmm').format(now);

      // Agregar página de portada
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'Reporte de Evaluaciones',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Fecha: ${DateFormat('dd/MM/yyyy').format(now)}'),
                pw.Text('Hora: $hora'),
                pw.SizedBox(height: 40),
                pw.Text(
                  'Este reporte contiene las estadísticas de las evaluaciones profesionales de los egresados.',
                  style: pw.TextStyle(fontSize: 14),
                ),
              ],
            );
          },
        ),
      );

      // Agregar página de estadísticas por carrera
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
          build: (pw.Context context) {
            final estadisticas = _calcularEstadisticasCarreras();
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('Distribución por Carrera'),
                ),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  headers: ['Carrera', 'Cantidad', 'Porcentaje'],
                  data: estadisticas.entries.map((e) {
                    final total = estadisticas.values.fold(0, (a, b) => a + b);
                    final porcentaje =
                        (e.value * 100 / total).toStringAsFixed(1);
                    return [e.key, e.value.toString(), '$porcentaje%'];
                  }).toList(),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.blue,
                  ),
                  cellHeight: 30,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.center,
                    2: pw.Alignment.center,
                  },
                ),
              ],
            );
          },
        ),
      );

      // Agregar página de empleo relacionado
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
          build: (pw.Context context) {
            final estadisticas = _calcularEstadisticasEmpleo();
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('Empleo Relacionado con la Carrera'),
                ),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  headers: ['Estado', 'Cantidad', 'Porcentaje'],
                  data: estadisticas.entries.map((e) {
                    final total = estadisticas.values.fold(0, (a, b) => a + b);
                    final porcentaje =
                        (e.value * 100 / total).toStringAsFixed(1);
                    return [e.key, e.value.toString(), '$porcentaje%'];
                  }).toList(),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.green,
                  ),
                  cellHeight: 30,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.center,
                    2: pw.Alignment.center,
                  },
                ),
              ],
            );
          },
        ),
      );

      // Agregar página de competencias
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
          build: (pw.Context context) {
            final competencias = _obtenerCompetenciasMasFrecuentes();
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('Competencias Más Frecuentes'),
                ),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  headers: ['Posición', 'Competencia'],
                  data: competencias
                      .asMap()
                      .entries
                      .map((e) => ['${e.key + 1}', e.value])
                      .toList(),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.amber,
                  ),
                  cellHeight: 30,
                  cellAlignments: {
                    0: pw.Alignment.center,
                    1: pw.Alignment.centerLeft,
                  },
                ),
              ],
            );
          },
        ),
      );

      // Guardar el PDF
      final bytes = await pdf.save();

      // Mostrar diálogo para guardar archivo
      final FileSaveLocation? saveLocation = await getSaveLocation(
        suggestedName: 'reporte_evaluaciones_${fecha}_${hora}.pdf',
        acceptedTypeGroups: [
          XTypeGroup(
            label: 'PDF',
            extensions: ['pdf'],
          ),
        ],
      );

      if (saveLocation != null) {
        final file = File(saveLocation.path);
        await file.writeAsBytes(bytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF guardado en: ${saveLocation.path}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar el PDF: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluaciones Profesionales'),
        actions: [
          if (_mostrarGraficas)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _exportarPDF,
              tooltip: 'Exportar a PDF',
            ),
          IconButton(
            icon: Icon(_mostrarGraficas ? Icons.list : Icons.bar_chart),
            onPressed: () {
              setState(() {
                _mostrarGraficas = !_mostrarGraficas;
              });
            },
            tooltip: _mostrarGraficas ? 'Ver Lista' : 'Ver Gráficas',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _evaluaciones.isEmpty
              ? const Center(
                  child: Text(
                    'No hay evaluaciones disponibles',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : _mostrarGraficas
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          _construirGraficaCarreras(),
                          _construirGraficaEmpleo(),
                          _construirCompetenciasFrecuentes(),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _evaluaciones.length,
                      itemBuilder: (context, index) {
                        final evaluacion = _evaluaciones[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(evaluacion['nombre']),
                            subtitle: Text(
                                '${evaluacion['correo']} - ${evaluacion['carrera']}'),
                            trailing: Text(
                              evaluacion['evaluacion']['fecha'] != null
                                  ? DateFormat('dd/MM/yyyy').format(
                                      DateTime.parse(
                                          evaluacion['evaluacion']['fecha']))
                                  : 'Sin fecha',
                            ),
                            onTap: () => _verEvaluacion(evaluacion),
                          ),
                        );
                      },
                    ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(
    this.text, {
    required this.size,
    required this.borderColor,
  });

  final String text;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: borderColor,
            fontSize: size * 0.3,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
