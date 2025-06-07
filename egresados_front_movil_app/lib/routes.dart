import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/documentos_screen.dart';

class Routes {
  static const String login = '/login';
  static const String home = '/home';
  static const String documentos = '/documentos';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      home: (context) => const HomeScreen(),
      documentos: (context) => const DocumentosScreen(),
    };
  }
}
