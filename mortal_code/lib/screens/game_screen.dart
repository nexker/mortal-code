import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/game_service.dart';
import '../services/firestore_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  final GameService _gameService = GameService();
  final FirestoreService _firestoreService = FirestoreService();

  int _nivel = 1;
  String _nombreNivel = 'Variables';
  int _vidas = 3;
  int _preguntaActual = 0;
  int _correctas = 0;
  static const int totalPreguntas = 5;

  bool _acercandose = false;
  bool _mostrandoPregunta = false;
  bool _cargandoPregunta = false;
  bool _mostrandoResultado = false;
  bool _resultadoCorrecto = false;
  bool _nivelCompletado = false;
  bool _mostrandoMuerte = false;

  Map<String, dynamic>? _preguntaData;
  String? _opcionSeleccionada;
  String _retroalimentacion = '';

  late AnimationController _deathController;
  late AnimationController _computerController;

  @override
  void initState() {
    super.initState();
    _deathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _computerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      _nivel = args['nivel'] ?? 1;
      _nombreNivel = args['nombreNivel'] ?? 'Variables';
    }
  }

  @override
  void dispose() {
    _deathController.dispose();
    _computerController.dispose();
    super.dispose();
  }

  Future<void> _acercarseAlComputador() async {
    setState(() => _acercandose = true);
    _computerController.forward();
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() {
      _acercandose = false;
      _mostrandoPregunta = true;
      _cargandoPregunta = true;
    });
    await _cargarPregunta();
  }

  Future<void> _cargarPregunta() async {
    try {
      final data = await _gameService.generarPregunta(_nivel);
      if (mounted) {
        setState(() {
          _preguntaData = data;
          _cargandoPregunta = false;
          _opcionSeleccionada = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _preguntaData = {
            'pregunta': 'Error al conectar con el servidor.\nVerifica que Flask esté corriendo.',
            'opciones': ['A) Reintentar'],
            'respuesta_correcta': 'A',
            'explicacion': 'Error de conexión.',
          };
          _cargandoPregunta = false;
        });
      }
    }
  }

Future<void> _responder(String opcion) async {
  if (_opcionSeleccionada != null || _mostrandoResultado) return;
  setState(() => _opcionSeleccionada = opcion);

  try {
    final resultado = await _gameService.validarRespuesta(
      pregunta: _preguntaData!['pregunta'],
      opcionSeleccionada: opcion,
      respuestaCorrecta: _preguntaData!['respuesta_correcta'],
      explicacion: _preguntaData!['explicacion'],
    );

    final bool correcto = resultado['correcto'] == true;

    if (correcto) _correctas++;
    else setState(() => _vidas--);

    setState(() {
      _resultadoCorrecto = correcto;
      _retroalimentacion = resultado['retroalimentacion'] ?? '';
      _mostrandoResultado = true;
    });

    if (!correcto && _vidas <= 0) {
      // No avanzar, esperar botón continuar para mostrar muerte
    }
  } catch (e) {
    setState(() {
      _retroalimentacion = 'Error al validar la respuesta.';
      _mostrandoResultado = true;
    });
  }
}

void _continuarSiguientePregunta() {
  if (!_resultadoCorrecto && _vidas <= 0) {
    _mostrarMuerte();
    return;
  }

  if (_correctas >= totalPreguntas) {
    _completarNivel();
    return;
  }

  setState(() {
    _mostrandoResultado = false;
    _cargandoPregunta = true;
    _opcionSeleccionada = null;
    _preguntaActual++;
  });
  _cargarPregunta();
}

  void _mostrarMuerte() {
    setState(() => _mostrandoMuerte = true);
    _deathController.forward();
  }

  Future<void> _completarNivel() async {
    await _firestoreService.actualizarProgreso(_nivel);
    setState(() => _nivelCompletado = true);
  }

  void _reiniciarNivel() {
    setState(() {
      _vidas = 3;
      _preguntaActual = 0;
      _correctas = 0;
      _mostrandoPregunta = false;
      _mostrandoResultado = false;
      _nivelCompletado = false;
      _mostrandoMuerte = false;
      _opcionSeleccionada = null;
      _preguntaData = null;
      _acercandose = false;
    });
    _deathController.reset();
    _computerController.reset();
  }

  @override
  Widget build(BuildContext context) {
    if (_mostrandoMuerte) return _buildMuerteScreen();
    if (_nivelCompletado) return _buildNivelCompletado();
    if (!_mostrandoPregunta) return _buildPrimeraPersona();
    if (_cargandoPregunta) return _buildCargandoPregunta();
    return _buildPregunta();
  }

Widget _buildPrimeraPersona() {
  return Scaffold(
    backgroundColor: Colors.black,
    body: GestureDetector(
      onTap: _acercarseAlComputador,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de fondo IBM completa con zoom al tocar
          Positioned.fill(
            child: AnimatedScale(
              scale: _acercandose ? 1.3 : 1.0,
              duration: const Duration(milliseconds: 800),
              child: Image.asset(
                'assets/images/COMPUTADOR_IBM.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay oscuro sutil
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
          // Header con vidas y nivel
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Color(0xFFAAAAAA)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'NIVEL $_nivel - $_nombreNivel',
                        style: GoogleFonts.pressStart2p(
                            fontSize: 9, color: const Color(0xFFFF0000)),
                      ),
                      const SizedBox(height: 4),
                      _buildVidas(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Instrucción tap
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF00FF00)),
              ),
              child: const Text(
                'Toca el computador para comenzar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF00FF00),
                  fontSize: 13,
                  fontFamily: 'Courier',
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildCargandoPregunta() {
    return Scaffold(
      backgroundColor: const Color(0xFF001A00),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💻', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: Color(0xFF00FF00)),
            const SizedBox(height: 20),
            const Text(
              'Generando pregunta...',
              style: TextStyle(
                  color: Color(0xFF00FF00),
                  fontFamily: 'Courier',
                  fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPregunta() {
    final opciones = List<String>.from(_preguntaData?['opciones'] ?? []);
    return Scaffold(
      backgroundColor: const Color(0xFF001A00),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('NIVEL $_nivel',
                      style: GoogleFonts.pressStart2p(
                          fontSize: 10, color: const Color(0xFFFF0000))),
                  Column(
                    children: [
                      Text('${_preguntaActual + 1}/$totalPreguntas',
                          style: const TextStyle(
                              color: Color(0xFF00FF00),
                              fontSize: 13,
                              fontFamily: 'Courier')),
                      _buildVidas(),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF001500),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _mostrandoResultado
                              ? (_resultadoCorrecto
                                  ? const Color(0xFF00FF00)
                                  : const Color(0xFFFF0000))
                              : const Color(0xFF00AA00),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'C:\\MORTAL_CODE\\NIVEL_$_nivel>',
                            style: const TextStyle(
                                color: Color(0xFF004400),
                                fontFamily: 'Courier',
                                fontSize: 11),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _preguntaData?['pregunta'] ?? '',
                            style: const TextStyle(
                                color: Color(0xFF00FF00),
                                fontFamily: 'Courier',
                                fontSize: 15,
                                height: 1.6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...opciones.map((opcion) {
                      final letra = opcion.isNotEmpty ? opcion[0] : '';
                      final esSeleccionada = _opcionSeleccionada == letra;
                      final esCorrecta =
                          _preguntaData?['respuesta_correcta'] == letra;

                      Color borderColor = const Color(0xFF2A4A2A);
                      Color bgColor = const Color(0xFF001200);
                      Color textColor = const Color(0xFF00CC00);

                      if (_mostrandoResultado && esSeleccionada) {
                        borderColor = _resultadoCorrecto
                            ? const Color(0xFF00FF00)
                            : const Color(0xFFFF0000);
                        bgColor = _resultadoCorrecto
                            ? const Color(0xFF002200)
                            : const Color(0xFF220000);
                        if (!_resultadoCorrecto) textColor = const Color(0xFFFF4444);
                      } else if (_mostrandoResultado && esCorrecta) {
                        borderColor = const Color(0xFF00FF00);
                        bgColor = const Color(0xFF001A00);
                      } else if (esSeleccionada) {
                        borderColor = const Color(0xFF00FF00);
                        bgColor = const Color(0xFF002200);
                      }

                      return GestureDetector(
                        onTap: () => _responder(letra),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(opcion,
                              style: TextStyle(
                                  color: textColor,
                                  fontFamily: 'Courier',
                                  fontSize: 14,
                                  height: 1.4)),
                        ),
                      );
                    }),
                    if (_mostrandoResultado && _retroalimentacion.isNotEmpty)
                      Column(
                        children: [
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _resultadoCorrecto
                                  ? const Color(0xFF002200)
                                  : const Color(0xFF220000),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: _resultadoCorrecto
                                      ? const Color(0xFF00FF00)
                                      : const Color(0xFFFF0000)),
                            ),
                            child: Text(
                              (_resultadoCorrecto ? '✅ ' : '❌ ') + _retroalimentacion,
                              style: TextStyle(
                                  color: _resultadoCorrecto
                                      ? const Color(0xFF00FF00)
                                      : const Color(0xFFFF4444),
                                  fontSize: 13,
                                  fontFamily: 'Courier',
                                  height: 1.5),
                            ),
                          ).animate().slideY(begin: 0.3, duration: 300.ms),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _continuarSiguientePregunta,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _resultadoCorrecto
                                    ? const Color(0xFF00AA00)
                                    : const Color(0xFF880000),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                _correctas >= totalPreguntas
                                    ? '¡COMPLETAR NIVEL!'
                                    : 'CONTINUAR →',
                                style: GoogleFonts.pressStart2p(fontSize: 10),
                              ),
                            ),
                          ).animate().fadeIn(delay: 300.ms),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuerteScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💀', style: TextStyle(fontSize: 100))
                .animate()
                .scale(duration: 600.ms)
                .then()
                .shake(duration: 400.ms),
            const SizedBox(height: 30),
            Text('GAME OVER',
                style: GoogleFonts.pressStart2p(
                    fontSize: 24, color: const Color(0xFFFF0000)))
                .animate()
                .fadeIn(delay: 400.ms),
            const SizedBox(height: 16),
            Text('No sobreviviste al nivel $_nivel',
                style: const TextStyle(color: Color(0xFF888888), fontSize: 14))
                .animate()
                .fadeIn(delay: 600.ms),
            if (_retroalimentacion.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A0A0A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFF0000)),
                ),
                child: Text(_retroalimentacion,
                    style: const TextStyle(
                        color: Color(0xFFAAAAAA), fontSize: 13, height: 1.5),
                    textAlign: TextAlign.center),
              ).animate().fadeIn(delay: 800.ms),
            ],
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _reiniciarNivel,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0000),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16)),
              child: Text('INTENTAR DE NUEVO',
                  style: GoogleFonts.pressStart2p(fontSize: 10)),
            ).animate().fadeIn(delay: 1000.ms),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver al mapa',
                  style: TextStyle(color: Color(0xFF888888))),
            ).animate().fadeIn(delay: 1100.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildNivelCompletado() {
    return Scaffold(
      backgroundColor: const Color(0xFF001A00),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 80))
                .animate()
                .scale(duration: 600.ms),
            const SizedBox(height: 24),
            Text('¡NIVEL COMPLETADO!',
                style: GoogleFonts.pressStart2p(
                    fontSize: 14, color: const Color(0xFF00FF00)),
                textAlign: TextAlign.center)
                .animate()
                .fadeIn(delay: 400.ms),
            const SizedBox(height: 12),
            Text('Nivel $_nivel - $_nombreNivel',
                style: const TextStyle(
                    color: Color(0xFF888888), fontSize: 15))
                .animate()
                .fadeIn(delay: 600.ms),
            const SizedBox(height: 8),
            const Text('Progreso guardado ✅',
                style: TextStyle(color: Color(0xFF00AA00), fontSize: 13))
                .animate()
                .fadeIn(delay: 800.ms),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AA00),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16)),
              child: Text('CONTINUAR',
                  style: GoogleFonts.pressStart2p(fontSize: 10)),
            ).animate().fadeIn(delay: 1000.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildVidas() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Text(i < _vidas ? '❤️' : '🖤',
            style: const TextStyle(fontSize: 14));
      }),
    );
  }
}

class _ParedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double y = 0; y < size.height; y += 60) {
      for (double x = 0; x < size.width; x += 80) {
        canvas.drawLine(Offset(x, y), Offset(x, y + 30), paint);
      }
      for (double x = 40; x < size.width; x += 80) {
        canvas.drawLine(Offset(x, y + 30), Offset(x, y + 60), paint);
      }
    }
    final grietaPaint = Paint()
      ..color = const Color(0xFF333333)
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(100, 20), const Offset(120, 80), grietaPaint);
    canvas.drawLine(const Offset(300, 10), const Offset(280, 70), grietaPaint);
  }

  @override
  bool shouldRepaint(_ParedPainter oldDelegate) => false;
}