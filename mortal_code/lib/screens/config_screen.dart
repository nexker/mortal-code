import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  bool _sonidoActivado = true;
  bool _musicaActivada = true;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sonidoActivado = prefs.getBool('sonido') ?? true;
      _musicaActivada = prefs.getBool('musica') ?? true;
    });
  }

  Future<void> _guardarPreferencia(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

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
          'CONFIGURACIÓN',
          style: GoogleFonts.pressStart2p(
            fontSize: 13,
            color: const Color(0xFFFF0000),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'AUDIO',
              style: GoogleFonts.pressStart2p(
                fontSize: 11,
                color: const Color(0xFF888888),
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 20),
            _buildOpcion(
              titulo: 'Efectos de sonido',
              subtitulo: 'Sonidos del juego y notificaciones',
              valor: _sonidoActivado,
              onChanged: (v) {
                setState(() => _sonidoActivado = v);
                _guardarPreferencia('sonido', v);
              },
            ).animate().slideX(begin: -0.3, duration: 400.ms),
            const SizedBox(height: 16),
            _buildOpcion(
              titulo: 'Música de fondo',
              subtitulo: 'Música ambiental de terror',
              valor: _musicaActivada,
              onChanged: (v) {
                setState(() => _musicaActivada = v);
                _guardarPreferencia('musica', v);
              },
            ).animate().slideX(begin: -0.3, duration: 500.ms),
            const SizedBox(height: 50),
            const Divider(color: Color(0xFF222222)),
            const SizedBox(height: 30),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/credits'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF444444)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people_outline,
                          color: Color(0xFF888888), size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'CRÉDITOS',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 11,
                          color: const Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcion({
    required String titulo,
    required String subtitulo,
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(subtitulo,
                    style: const TextStyle(
                        color: Color(0xFF666666), fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: valor,
            onChanged: onChanged,
            activeColor: const Color(0xFFFF0000),
            inactiveThumbColor: const Color(0xFF444444),
            inactiveTrackColor: const Color(0xFF222222),
          ),
        ],
      ),
    );
  }
}