import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _carrera = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  String? _error;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final response = await _authService.register(
      _nombre.text.trim(),
      _correo.text.trim(),
      _carrera.text.trim(),
      _password.text.trim(),
    );

    setState(() {
      _loading = false;
    });

    if (response['ok']) {
      Navigator.pop(context);
    } else {
      setState(() {
        _error = response['message'];
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
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    );
  }

  @override
Widget build(BuildContext context) {
  final primaryColor = Colors.blue.shade700;

  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Registro de Egresado',
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
    ),
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.blue.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 480,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                      controller: _nombre,
                      decoration: _inputDecoration('Nombre completo'),
                      validator: (v) => v!.isEmpty ? 'Nombre obligatorio' : null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _correo,
                      decoration: _inputDecoration('Correo institucional'),
                      validator: (v) => v!.endsWith('@campusucc.edu.co')
                          ? null
                          : 'Debe usar su correo @campusucc.edu.co',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _carrera,
                      decoration: _inputDecoration('Carrera'),
                      validator: (v) => v!.isEmpty ? 'Carrera obligatoria' : null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _password,
                      decoration: _inputDecoration('Contraseña'),
                      obscureText: true,
                      validator: (v) =>
                          v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 36),
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _register,
                              icon: const Icon(Icons.person_add_alt_1, size: 28),
                              label: const Text(
                                'Registrarse',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shadowColor: Colors.black45,
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                                animationDuration: const Duration(milliseconds: 250),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}
