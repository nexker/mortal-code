import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:mortal_code/services/game_service.dart';

class MockHttpClient extends Mock implements http.Client {}
class MockResponse extends Mock implements http.Response {}
class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  late MockHttpClient mockClient;
  late GameService gameService;

  setUp(() {
    mockClient = MockHttpClient();
    gameService = GameService(client: mockClient);
  });

  group('GameService - generarPregunta', () {
    test('retorna pregunta correctamente cuando el servidor responde 200', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.body).thenReturn('''
        {
          "pregunta": "¿Qué es una variable en Python?",
          "opciones": ["A) Un dato", "B) Una función", "C) Un módulo", "D) Una clase"],
          "respuesta_correcta": "A",
          "explicacion": "Una variable almacena datos."
        }
      ''');

      when(() => mockClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => mockResponse);

      final resultado = await gameService.generarPregunta(1);

      expect(resultado['pregunta'], equals('¿Qué es una variable en Python?'));
      expect(resultado['respuesta_correcta'], equals('A'));
      expect(resultado['opciones'], hasLength(4));
    });

    test('lanza excepción cuando el servidor responde 500', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(500);
      when(() => mockResponse.body).thenReturn('{"error": "Error interno"}');

      when(() => mockClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => mockResponse);

      expect(
        () => gameService.generarPregunta(1),
        throwsException,
      );
    });

    test('lanza excepción cuando hay error de conexión', () async {
      when(() => mockClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      )).thenThrow(Exception('Connection refused'));

      expect(
        () => gameService.generarPregunta(1),
        throwsException,
      );
    });
  });

  group('GameService - validarRespuesta', () {
    test('retorna correcto true cuando la respuesta es correcta', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.body).thenReturn('''
        {
          "correcto": true,
          "retroalimentacion": "¡Correcto! Una variable almacena datos."
        }
      ''');

      when(() => mockClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => mockResponse);

      final resultado = await gameService.validarRespuesta(
        pregunta: '¿Qué es una variable?',
        opcionSeleccionada: 'A',
        respuestaCorrecta: 'A',
        explicacion: 'Una variable almacena datos.',
      );

      expect(resultado['correcto'], isTrue);
      expect(resultado['retroalimentacion'], contains('Correcto'));
    });

    test('retorna correcto false cuando la respuesta es incorrecta', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.body).thenReturn('''
        {
          "correcto": false,
          "retroalimentacion": "Incorrecto. La respuesta correcta era A."
        }
      ''');

      when(() => mockClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => mockResponse);

      final resultado = await gameService.validarRespuesta(
        pregunta: '¿Qué es una variable?',
        opcionSeleccionada: 'B',
        respuestaCorrecta: 'A',
        explicacion: 'Una variable almacena datos.',
      );

      expect(resultado['correcto'], isFalse);
      expect(resultado['retroalimentacion'], contains('Incorrecto'));
    });

    test('lanza excepción cuando el servidor responde 500', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(500);
      when(() => mockResponse.body).thenReturn('{"error": "Error"}');

      when(() => mockClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => mockResponse);

      expect(
        () => gameService.validarRespuesta(
          pregunta: '¿Qué es una variable?',
          opcionSeleccionada: 'A',
          respuestaCorrecta: 'A',
          explicacion: 'Explicación.',
        ),
        throwsException,
      );
    });
  });
}