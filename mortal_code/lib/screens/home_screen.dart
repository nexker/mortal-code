import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  int _nivelActual = 0;
  late AnimationController _flickerController;

  static const int totalNiveles = 8;
  static const List<String> nombresNiveles = [
    'Variables', 'Condicionales', 'Bucles',
    'Funciones', 'Listas', 'Diccionarios',
    'Clases', 'Módulos',
  ];

  @override
  void initState() {
    super.initState();
    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _cargarProgreso();
  }

  @override
  void dispose() {
    _flickerController.dispose();
    super.dispose();
  }

  Future<void> _cargarProgreso() async {
    final progreso = await _firestoreService.obtenerProgreso();
    if (mounted) {
      setState(() => _nivelActual = progreso);
    }
  }

  Future<void> _confirmarReinicio() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A0A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFFF0000)),
        ),
        title: Text(
          '⚠️ ¿Estás seguro?',
          style: GoogleFonts.pressStart2p(
            fontSize: 13,
            color: const Color(0xFFFF0000),
          ),
        ),
        content: const Text(
          'Se borrará todo tu progreso.\nEsta acción no se puede deshacer.',
          style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR',
                style: TextStyle(color: Color(0xFF888888))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF0000),
            ),
            child: const Text('REINICIAR',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      await _firestoreService.reiniciarProgreso();
      setState(() => _nivelActual = 0);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Progreso reiniciado'),
            backgroundColor: Color(0xFF1A1A1A),
          ),
        );
      }
    }
  }

  void _mostrarInfoPython() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1A0D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF00FF00)),
        ),
        title: Text(
          '¿Qué es Python?',
          style: GoogleFonts.pressStart2p(
            fontSize: 13,
            color: const Color(0xFF00FF00),
          ),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Python es un lenguaje de programación de alto nivel, '
            'interpretado y de propósito general.\n\n'
            '🐍 Creado por Guido van Rossum en 1991\n\n'
            '✅ Fácil de aprender y leer\n'
            '✅ Usado en IA, web, ciencia de datos\n'
            '✅ Gran comunidad mundial\n'
            '✅ Sintaxis clara y concisa\n\n'
            'En este juego aprenderás sus fundamentos '
            'resolviendo desafíos nivel por nivel.',
            style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 13, height: 1.6),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF00),
            ),
            child: const Text('CERRAR',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          // Fondo gradiente nocturno
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF050510),
                  Color(0xFF0D0D0D),
                  Color(0xFF1A0D00),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MORTAL CODE',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 14,
                          color: const Color(0xFFFF0000),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Color(0xFF888888)),
                        onPressed: () async {
                          await _authService.signOut();
                          if (!mounted) return;
                          final nav = Navigator.of(context);
                          nav.pushReplacementNamed('/login');
                        },
                      ),
                    ],
                  ),
                ),
                // Edificio
                Expanded(
                  child: _EdificioWidget(
                    nivelActual: _nivelActual,
                    totalNiveles: totalNiveles,
                    flickerController: _flickerController,
                  ),
                ),
                // Botones
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Nivel actual
                      if (_nivelActual < totalNiveles)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A00),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFFAA00)),
                          ),
                          child: Text(
                            'Nivel ${_nivelActual + 1}: ${nombresNiveles[_nivelActual]}',
                            style: const TextStyle(
                              color: Color(0xFFFFAA00),
                              fontSize: 13,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: _BotonMenu(
                              texto: 'COMENZAR',
                              color: const Color(0xFFFF0000),
                              onTap: () => Navigator.pushNamed(context, '/map')
                                .then((_) => _cargarProgreso()),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _BotonMenu(
                              texto: '¿QUÉ ES\nPYTHON?',
                              color: const Color(0xFF00AA00),
                              onTap: _mostrarInfoPython,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _BotonMenu(
                              texto: 'CONFIGURACIÓN',
                              color: const Color(0xFF444444),
                              onTap: () => Navigator.pushNamed(context, '/config'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _BotonMenu(
                              texto: 'REINICIAR\nPROGRESO',
                              color: const Color(0xFF2A0A0A),
                              borderColor: const Color(0xFFFF0000),
                              onTap: _confirmarReinicio,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EdificioWidget extends StatelessWidget {
  final int nivelActual;
  final int totalNiveles;
  final AnimationController flickerController;

  const _EdificioWidget({
    required this.nivelActual,
    required this.totalNiveles,
    required this.flickerController,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _EdificioPainter(
        nivelActual: nivelActual,
        totalNiveles: totalNiveles,
        flickerValue: flickerController.value,
      ),
      child: AnimatedBuilder(
        animation: flickerController,
        builder: (context, child) => const SizedBox.expand(),
      ),
    );
  }
}

class _EdificioPainter extends CustomPainter {
  final int nivelActual;
  final int totalNiveles;
  final double flickerValue;

  _EdificioPainter({
    required this.nivelActual,
    required this.totalNiveles,
    required this.flickerValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ── CIELO NOCTURNO ──────────────────────────────────────────────
    final cieloPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF020208),
          const Color(0xFF0A0A1A),
          const Color(0xFF0D0D0D),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), cieloPaint);

    // Luna
    final lunaPaint = Paint()..color = const Color(0xFFDDCC88).withValues(alpha: 0.6);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.1), 22, lunaPaint);
    final lunaOscura = Paint()..color = const Color(0xFF050510);
    canvas.drawCircle(Offset(size.width * 0.8 + 8, size.height * 0.1 - 4), 18, lunaOscura);

    // Estrellas
    final estrellasPaint = Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.6);
    final estrellas = [
      Offset(size.width * 0.1, size.height * 0.05),
      Offset(size.width * 0.25, size.height * 0.03),
      Offset(size.width * 0.4, size.height * 0.07),
      Offset(size.width * 0.6, size.height * 0.04),
      Offset(size.width * 0.15, size.height * 0.12),
      Offset(size.width * 0.55, size.height * 0.09),
      Offset(size.width * 0.7, size.height * 0.13),
      Offset(size.width * 0.9, size.height * 0.06),
    ];
    for (final estrella in estrellas) {
      canvas.drawCircle(estrella, 1.2, estrellasPaint);
    }

    // ── EDIFICIO PRINCIPAL ──────────────────────────────────────────
    final double edificioAncho = size.width * 0.58;
    final double edificioX = (size.width - edificioAncho) / 2;
    final double edificioAlto = size.height * 0.88;
    final double edificioY = size.height - edificioAlto;

    // Sombra del edificio
    final sombraPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawRect(
      Rect.fromLTWH(edificioX + 15, edificioY + 15, edificioAncho, edificioAlto),
      sombraPaint,
    );

    // Cuerpo principal del edificio
    final edificioPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1C1C1C),
          const Color(0xFF141414),
          const Color(0xFF0E0E0E),
        ],
      ).createShader(Rect.fromLTWH(edificioX, edificioY, edificioAncho, edificioAlto));
    canvas.drawRect(
      Rect.fromLTWH(edificioX, edificioY, edificioAncho, edificioAlto),
      edificioPaint,
    );

    // ── LADRILLOS ───────────────────────────────────────────────────
    final ladrilloPaint = Paint()
      ..color = const Color(0xFF222222)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const double alturaLadrillo = 14.0;
    const double anchoLadrillo = 28.0;

    for (double y = edificioY; y < edificioY + edificioAlto; y += alturaLadrillo) {
      final bool filaPar = ((y - edificioY) / alturaLadrillo).floor().isEven;
      final double offsetX = filaPar ? 0 : anchoLadrillo / 2;
      canvas.drawLine(
        Offset(edificioX, y),
        Offset(edificioX + edificioAncho, y),
        ladrilloPaint,
      );
      for (double x = edificioX + offsetX; x < edificioX + edificioAncho; x += anchoLadrillo) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, y + alturaLadrillo),
          ladrilloPaint,
        );
      }
    }

    // ── GRIETAS ─────────────────────────────────────────────────────
    final grietaPaint = Paint()
      ..color = const Color(0xFF000000).withValues(alpha: 0.7)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final grietas = [
      [Offset(edificioX + 20, edificioY + 30), Offset(edificioX + 35, edificioY + 80)],
      [Offset(edificioX + 35, edificioY + 80), Offset(edificioX + 25, edificioY + 120)],
      [Offset(edificioX + edificioAncho - 30, edificioY + 50), Offset(edificioX + edificioAncho - 15, edificioY + 100)],
      [Offset(edificioX + 60, edificioY + 200), Offset(edificioX + 45, edificioY + 260)],
      [Offset(edificioX + edificioAncho - 50, edificioY + 300), Offset(edificioX + edificioAncho - 35, edificioY + 360)],
    ];

    for (final grieta in grietas) {
      canvas.drawLine(grieta[0], grieta[1], grietaPaint);
    }

    // ── VENTANAS ────────────────────────────────────────────────────
    final double alturaPiso = edificioAlto / (totalNiveles + 1);
    final double ventanaAncho = edificioAncho * 0.20;
    final double ventanaAlto = alturaPiso * 0.48;

    for (int piso = 0; piso < totalNiveles; piso++) {
      final double pisoY = edificioY + edificioAlto - (piso + 1) * alturaPiso;
      final bool completado = piso < nivelActual;
      final bool esActual = piso == nivelActual;

      for (int col = 0; col < 2; col++) {
        final double ventanaX = edificioX +
            edificioAncho * (col == 0 ? 0.20 : 0.62) -
            ventanaAncho / 2;
        final double ventanaY = pisoY + (alturaPiso - ventanaAlto) / 2;

        // Sombra ventana
        final sombVentana = Paint()
          ..color = Colors.black.withValues(alpha: 0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawRect(
          Rect.fromLTWH(ventanaX + 2, ventanaY + 2, ventanaAncho, ventanaAlto),
          sombVentana,
        );

        // Interior ventana
        Color colorInterior;
        if (completado) {
          colorInterior = const Color(0xFF1A1200);
        } else if (esActual) {
          colorInterior = const Color(0xFF001500);
        } else {
          colorInterior = const Color(0xFF080808);
        }

        canvas.drawRect(
          Rect.fromLTWH(ventanaX, ventanaY, ventanaAncho, ventanaAlto),
          Paint()..color = colorInterior,
        );

        // Luz de ventana (glow)
        if (completado) {
          final brilloPaint = Paint()
            ..color = const Color(0xFFFFAA00).withValues(alpha: 0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
          canvas.drawRect(
            Rect.fromLTWH(ventanaX - 6, ventanaY - 6, ventanaAncho + 12, ventanaAlto + 12),
            brilloPaint,
          );
          // Luz interior cálida
          canvas.drawRect(
            Rect.fromLTWH(ventanaX + 2, ventanaY + 2, ventanaAncho - 4, ventanaAlto - 4),
            Paint()..color = const Color(0xFFFFAA00).withValues(alpha: 0.15),
          );
        } else if (esActual) {
          final double brillo = 0.3 + flickerValue * 0.4;
          final brilloPaint = Paint()
            ..color = const Color(0xFF00FF00).withValues(alpha: brillo * 0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
          canvas.drawRect(
            Rect.fromLTWH(ventanaX - 8, ventanaY - 8, ventanaAncho + 16, ventanaAlto + 16),
            brilloPaint,
          );
          canvas.drawRect(
            Rect.fromLTWH(ventanaX + 2, ventanaY + 2, ventanaAncho - 4, ventanaAlto - 4),
            Paint()..color = const Color(0xFF00FF00).withValues(alpha: brillo * 0.2),
          );
        }

        // Marco de la ventana (roto)
        final marcoPaint = Paint()
          ..color = const Color(0xFF3A3A3A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawRect(
          Rect.fromLTWH(ventanaX, ventanaY, ventanaAncho, ventanaAlto),
          marcoPaint,
        );

        // Divisiones internas de la ventana
        final divPaint = Paint()
          ..color = const Color(0xFF2A2A2A)
          ..strokeWidth = 1.0;
        // Vertical
        canvas.drawLine(
          Offset(ventanaX + ventanaAncho / 2, ventanaY),
          Offset(ventanaX + ventanaAncho / 2, ventanaY + ventanaAlto),
          divPaint,
        );
        // Horizontal
        canvas.drawLine(
          Offset(ventanaX, ventanaY + ventanaAlto / 2),
          Offset(ventanaX + ventanaAncho, ventanaY + ventanaAlto / 2),
          divPaint,
        );

        // Vidrio roto en ventanas apagadas
        if (!completado && !esActual) {
          final rotoPaint = Paint()
            ..color = const Color(0xFF1A1A1A)
            ..strokeWidth = 0.8;
          canvas.drawLine(
            Offset(ventanaX + ventanaAncho * 0.3, ventanaY),
            Offset(ventanaX + ventanaAncho * 0.6, ventanaY + ventanaAlto),
            rotoPaint,
          );
          canvas.drawLine(
            Offset(ventanaX, ventanaY + ventanaAlto * 0.4),
            Offset(ventanaX + ventanaAncho * 0.7, ventanaY + ventanaAlto * 0.8),
            rotoPaint,
          );
        }
      }
    }

    // ── CONTORNO EDIFICIO ───────────────────────────────────────────
    final contornoPaint = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(
      Rect.fromLTWH(edificioX, edificioY, edificioAncho, edificioAlto),
      contornoPaint,
    );

    // ── EDIFICIOS DE FONDO ──────────────────────────────────────────
    _dibujarEdificioFondo(canvas, size, edificioX - 80, size.height * 0.45, 70, size.height * 0.55);
    _dibujarEdificioFondo(canvas, size, edificioX + edificioAncho + 10, size.height * 0.5, 60, size.height * 0.5);

    // ── SUELO ───────────────────────────────────────────────────────
    final sueloPaint = Paint()..color = const Color(0xFF111111);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 3, size.width, 25),
      sueloPaint,
    );

    // Niebla en la base
    final nieblaPaint = Paint()
      ..color = const Color(0xFF1A1A2A).withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 50, size.width, 30),
      nieblaPaint,
    );
  }    

  void _dibujarEdificioFondo(Canvas canvas, Size size, double x, double y, double ancho, double alto) {
    final paint = Paint()..color = const Color(0xFF0A0A0A);
    canvas.drawRect(Rect.fromLTWH(x, y, ancho, alto), paint);

    final contorno = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawRect(Rect.fromLTWH(x, y, ancho, alto), contorno);

    // Ventanas pequeñas del fondo
    final ventPaint = Paint()..color = const Color(0xFF0F0F0F);
    for (double vy = y + 10; vy < y + alto - 10; vy += 18) {
      for (double vx = x + 8; vx < x + ancho - 8; vx += 16) {
        canvas.drawRect(Rect.fromLTWH(vx, vy, 8, 10), ventPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_EdificioPainter oldDelegate) {
    return oldDelegate.flickerValue != flickerValue ||
        oldDelegate.nivelActual != nivelActual;
  }
}

class _BotonMenu extends StatelessWidget {
  final String texto;
  final Color color;
  final Color? borderColor;
  final VoidCallback onTap;

  const _BotonMenu({
    required this.texto,
    required this.color,
    required this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1.5)
              : null,
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: GoogleFonts.pressStart2p(
            fontSize: 9,
            color: Colors.white,
            height: 1.6,
          ),
        ),
      ),
    ).animate().scale(duration: 150.ms);
  }
}