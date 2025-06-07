import 'package:flutter/material.dart';

import '../services/PerfilService.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final response = await _authService.login(
      _correoController.text.trim(),
      _passwordController.text.trim(),
    );

    if (response['ok']) {
      final perfilService = PerfilService();
      final estado = await perfilService.obtenerEstadoHabilitacion();

      setState(() {
        _loading = false;
      });

      if (estado == true) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (estado == false) {
        Navigator.pushReplacementNamed(context, '/no-habilitado');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al verificar el estado de habilitación'),
          ),
        );
      }
    } else {
      setState(() {
        _loading = false;
        _error = response['message'] ?? 'Error desconocido';
      });
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.blue.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade700;
    final secondaryColor = Colors.blue.shade300;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Egresado'),
        centerTitle: true,
        elevation: 6,
        backgroundColor: primaryColor,
        shadowColor: Colors.black45,
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [secondaryColor.withOpacity(0.6), primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              children: [
                Icon(
                  Icons.account_circle_rounded,
                  size: 120,
                  color: primaryColor.withOpacity(0.8),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bienvenido de nuevo',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 4,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Por favor inicia sesión para continuar',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      TextFormField(
                        controller: _correoController,
                        decoration: _inputDecoration('Correo'),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Ingrese su correo'
                                    : null,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        decoration: _inputDecoration('Contraseña'),
                        obscureText: true,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Ingrese su contraseña'
                                    : null,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 36),
                      _loading
                          ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                          : SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 6,
                                shadowColor: Colors.black38,
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('Iniciar Sesión'),
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
