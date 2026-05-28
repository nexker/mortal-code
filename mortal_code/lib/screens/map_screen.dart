import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/firestore_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  int _nivelDesbloqueado = 0;

  static const List<Map<String, dynamic>> niveles = [
    {'nombre': 'Variables', 'descripcion': 'Almacena datos', 'icono': '📦', 'piso': 1},
    {'nombre': 'Condicionales', 'descripcion': 'if / elif / else', 'icono': '🔀', 'piso': 2},
    {'nombre': 'Bucles', 'descripcion': 'for y while', 'icono': '🔄', 'piso': 3},
    {'nombre': 'Funciones', 'descripcion': 'def y return', 'icono': '⚡', 'piso': 4},
    {'nombre': 'Listas', 'descripcion': 'Colecciones', 'icono': '📋', 'piso': 5},
    {'nombre': 'Diccionarios', 'descripcion': 'Clave - Valor', 'icono': '🗂️', 'piso': 6},
    {'nombre': 'Clases', 'descripcion': 'POO en Python', 'icono': '🏛️', 'piso': 7},
    {'nombre': 'Módulos', 'descripcion': 'import y export', 'icono': '📦', 'piso': 8},
  ];

  @override
  void initState() {
    super.initState();
    _cargarProgreso();
  }

  Future<void> _cargarProgreso() async {
    final progreso = await _firestoreService.obtenerProgreso();
    if (mounted) setState(() => _nivelDesbloqueado = progreso);
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
          'MAPA DE NIVELES',
          style: GoogleFonts.pressStart2p(
            fontSize: 11,
            color: const Color(0xFFFF0000),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Fondo edificio
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF050510), Color(0xFF0D0D0D)],
              ),
            ),
          ),
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: niveles.length,
            reverse: true, // Nivel 1 abajo, último arriba
            itemBuilder: (context, index) {
              final nivel = niveles[index];
              final numeroNivel = index + 1;
              final desbloqueado = index <= _nivelDesbloqueado;
              final completado = index < _nivelDesbloqueado;
              final esActual = index == _nivelDesbloqueado;

              return Column(
                children: [
                  // Línea conectora (excepto el último nivel)
                  if (index < niveles.length - 1)
                    Container(
                      width: 2,
                      height: 30,
                      color: completado
                          ? const Color(0xFFFFAA00)
                          : const Color(0xFF333333),
                    ),
                  // Nodo del nivel
                  GestureDetector(
                    onTap: desbloqueado
                        ? () {
                            Navigator.pushNamed(
                              context,
                              '/game',
                              arguments: {
                                'nivel': numeroNivel,
                                'nombreNivel': nivel['nombre'],
                              },
                            ).then((_) => _cargarProgreso());
                          }
                        : null,
                    child: _NodoNivel(
                      numero: numeroNivel,
                      nombre: nivel['nombre'],
                      descripcion: nivel['descripcion'],
                      icono: nivel['icono'],
                      piso: nivel['piso'],
                      desbloqueado: desbloqueado,
                      completado: completado,
                      esActual: esActual,
                    ).animate().slideX(
                          begin: index.isEven ? -0.3 : 0.3,
                          delay: Duration(milliseconds: index * 80),
                          duration: 400.ms,
                        ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NodoNivel extends StatelessWidget {
  final int numero;
  final String nombre;
  final String descripcion;
  final String icono;
  final int piso;
  final bool desbloqueado;
  final bool completado;
  final bool esActual;

  const _NodoNivel({
    required this.numero,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.piso,
    required this.desbloqueado,
    required this.completado,
    required this.esActual,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    Color textColor;

    if (completado) {
      borderColor = const Color(0xFFFFAA00);
      bgColor = const Color(0xFF1A1200);
      textColor = const Color(0xFFFFAA00);
    } else if (esActual) {
      borderColor = const Color(0xFF00FF00);
      bgColor = const Color(0xFF001A00);
      textColor = const Color(0xFF00FF00);
    } else {
      borderColor = const Color(0xFF333333);
      bgColor = const Color(0xFF111111);
      textColor = const Color(0xFF555555);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: esActual ? 2 : 1,
        ),
        boxShadow: esActual
            ? [
                BoxShadow(
                  color: const Color(0xFF00FF00).withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Row(
        children: [
          // Número del piso / icono
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: desbloqueado
                  ? borderColor.withOpacity(0.15)
                  : const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor.withOpacity(0.5)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  desbloqueado ? icono : '🔒',
                  style: const TextStyle(fontSize: 22),
                ),
                Text(
                  'P$piso',
                  style: TextStyle(
                    color: borderColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'NIVEL $numero',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 9,
                        color: textColor,
                      ),
                    ),
                    if (completado) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle,
                          color: Color(0xFFFFAA00), size: 16),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  nombre,
                  style: TextStyle(
                    color: desbloqueado ? Colors.white : const Color(0xFF555555),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  descripcion,
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Flecha si está desbloqueado
          if (desbloqueado && !completado)
            Icon(
              Icons.arrow_forward_ios,
              color: borderColor,
              size: 18,
            ),
        ],
      ),
    );
  }
}