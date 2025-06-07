import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'cargar_excel_screen.dart';
import 'egresados_screen.dart';
import 'evaluaciones_screen.dart';
import 'notificaciones_screen.dart';
import 'pdfs_unificados_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implementar notificaciones
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: MediaQuery.of(context).size.width > 1200
            ? 4
            : MediaQuery.of(context).size.width > 800
                ? 3
                : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildDashboardCard(
            context,
            'Egresados',
            Icons.people,
            Colors.blue,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EgresadosScreen(),
                ),
              );
            },
          ),
          _buildDashboardCard(
            context,
            'Cargar Excel',
            Icons.upload_file,
            Colors.indigo,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CargarExcelScreen(),
                ),
              );
            },
          ),
          _buildDashboardCard(
            context,
            'Notificaciones',
            Icons.notifications_active,
            Colors.orange,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificacionesScreen(),
                ),
              );
            },
          ),
          _buildDashboardCard(
            context,
            'Evaluaciones',
            Icons.assignment,
            Colors.green,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EvaluacionesScreen(),
                ),
              );
            },
          ),
          _buildDashboardCard(
            context,
            'Documentos',
            Icons.folder,
            Colors.purple,
            () {
              // TODO: Navegar a gestión de documentos
            },
          ),
          _buildDashboardCard(
            context,
            'PDFs Unificados',
            Icons.picture_as_pdf,
            Colors.red,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PDFsUnificadosScreen(),
                ),
              );
            },
          ),
          _buildDashboardCard(
            context,
            'Estadísticas',
            Icons.bar_chart,
            Colors.teal,
            () {
              // TODO: Navegar a estadísticas
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.7),
                color,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
