import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  Future<void> init() async {}
  Future<void> reproducirMusica() async {}
  Future<void> detenerMusica() async {}
  Future<void> sonidoCorrecto() async {}
  Future<void> sonidoIncorrecto() async {}
  Future<void> sonidoGameOver() async {}
  Future<void> sonidoNivelCompleto() async {}
  Future<void> actualizarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.getBool('sonido');
    prefs.getBool('musica');
  }
  void dispose() {}
}