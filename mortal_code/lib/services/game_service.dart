import 'dart:convert';
import 'package:http/http.dart' as http;

class GameService {
  // ⚠️ Cambia esta IP por la IP de tu PC cuando corras Flask
  // Puedes verla con: ipconfig en PowerShell
  static const String _baseUrl = 'http://192.168.20.22:5000'; // Android emulator
  // static const String _baseUrl = 'http://192.168.x.x:5000'; // Dispositivo real

  final http.Client _client;

  GameService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> generarPregunta(int nivel) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/generar-pregunta'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nivel': nivel}),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error ${response.statusCode}: ${response.body}');
  }

  Future<Map<String, dynamic>> validarRespuesta({
    required String pregunta,
    required String opcionSeleccionada,
    required String respuestaCorrecta,
    required String explicacion,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/validar-respuesta'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'pregunta': pregunta,
        'opcion_seleccionada': opcionSeleccionada,
        'respuesta_correcta': respuestaCorrecta,
        'explicacion': explicacion,
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error ${response.statusCode}: ${response.body}');
  }
}