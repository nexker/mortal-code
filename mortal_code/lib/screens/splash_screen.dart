import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo imagen
            Image.asset(
              'assets/images/MORTAL_CODE_LOGO.png',
              width: 280,
            )
                .animate()
                .fadeIn(duration: 1200.ms)
                .then()
                .shimmer(
                  duration: 1500.ms,
                  color: const Color(0xFFFF4444),
                ),
            const SizedBox(height: 40),
            Text(
              'Aprende Python... si puedes',
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 12,
                letterSpacing: 2,
                fontFamily: 'Courier',
              ),
            ).animate().fadeIn(delay: 800.ms, duration: 1000.ms),
            const SizedBox(height: 60),
            SizedBox(
              width: 280,
              child: Column(
                children: [
                  LinearProgressIndicator(
                    backgroundColor: const Color(0xFF1A1A1A),
                    color: const Color(0xFFFF0000),
                    minHeight: 4,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Cargando...',
                    style: TextStyle(
                      color: Color(0xFF555555),
                      fontSize: 11,
                      fontFamily: 'Courier',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}