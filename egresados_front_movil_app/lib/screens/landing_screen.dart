 import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade700;
    final secondaryColor = Colors.blue.shade300;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [secondaryColor.withOpacity(0.6), primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Alumni',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 6,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryColor,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 6,
                    shadowColor: Colors.black38,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Registrarse'),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white, width: 2),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Iniciar Sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}