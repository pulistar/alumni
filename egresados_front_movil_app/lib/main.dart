import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/documentos_screen.dart';
import 'screens/estado_habilitacion_widget.dart'; // Importación nueva
import 'screens/evaluacion_screen.dart';
import 'screens/home_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/no_habilitado_screen.dart';
import 'screens/notificaciones_screen.dart';
import 'screens/register_screen.dart';
import 'screens/subir_documentos_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Egresado',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (_) => const LandingScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/register': (_) => const RegisterScreen(),
        '/estado':
            (_) => EstadoHabilitacionWidget(), // Nueva ruta para ver estado
        '/no-habilitado': (_) => const NoHabilitadoScreen(),
        '/subir-documentos': (_) => const SubirDocumentosScreen(),
        '/evaluacion': (_) => const EvaluacionScreen(),
        '/documentos': (_) => const DocumentosScreen(),
        '/notificaciones': (_) => const NotificacionesScreen(),
      },
    );
  }
}
