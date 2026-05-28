import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFAAAAAA)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'CRÉDITOS',
          style: GoogleFonts.pressStart2p(
            fontSize: 13,
            color: const Color(0xFFFF0000),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Logo imagen
            const SizedBox(height: 20),
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
            Text(
              'Videojuego Educativo de Python',
              style: TextStyle(
                color: const Color(0xFF888888),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 40),
            _buildSeccion(
              titulo: '🏛️ UNIVERSIDAD',
              contenido: [
                // ← Cambia esto con el nombre real de tu universidad
                'Universidad Libre de Colombia',
                'Facultad de Ingeniería',
                'Programa de Ingeniería de Sistemas',
                'Programación móvil',
              ],
              delay: 200,
            ),
            const SizedBox(height: 24),
            _buildSeccion(
              titulo: '👥 EQUIPO DE DESARROLLO',
              contenido: [
                // ← Agrega los nombres reales de tus compañeros aquí
                '• Nelson Ayala - Scrum Master & Product Owner.',
                '• Nelson Ayala, Daniel Palencia - Programadores.',
                '• Nelson Ayala, Daniel Palencia - Diseñador Gráfico.',
                '• Nelson Ayala, Daniel Palencia, Michaell Romero - Documentacion.',
                '• Juan Osorio, Daniel Palencia, Michaell Romero, Camilo Salamanca- Tester & QA.',
              ],
              delay: 400,
            ),
            const SizedBox(height: 24),
            _buildSeccion(
              titulo: '🎓 AGRADECIMIENTOS',
              contenido: [
                // ← Agrega el nombre real del profesor
                'Al profesor Roger Enrique Guzman Avendaño\npor su guía y enseñanza durante\nel desarrollo de este proyecto.',
                '',
                'A todos los que creyeron que\naprender a programar podía ser\nmucho mas divertido. 🎃',
              ],
              delay: 600,
            ),
            const SizedBox(height: 24),
            _buildSeccion(
              titulo: '🛠️ TECNOLOGÍAS',
              contenido: [
                '• Flutter & Dart',
                '• Firebase Auth & Firestore',
                '• Google Gemini AI',
                '• Python & Flask',
              ],
              delay: 800,
            ),
            const SizedBox(height: 40),
            Text(
              '© 2026 Mortal Code\nTodos los derechos reservados',
              style: const TextStyle(
                color: Color(0xFF444444),
                fontSize: 11,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 1000.ms),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccion({
    required String titulo,
    required List<String> contenido,
    required int delay,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Color(0xFFFF0000),
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          ...contenido.map(
            (linea) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                linea,
                style: const TextStyle(
                  color: Color(0xFFCCCCCC),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(
          begin: 0.3,
          delay: Duration(milliseconds: delay),
          duration: 400.ms,
        );
  }
}