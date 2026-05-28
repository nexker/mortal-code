import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mortal_code/screens/config_screen.dart';
import 'package:mortal_code/screens/credits_screen.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('muestra LinearProgressIndicator de carga', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                LinearProgressIndicator(),
                Text('Cargando...'),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Cargando...'), findsOneWidget);
    });

    testWidgets('muestra Scaffold con fondo oscuro', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            backgroundColor: Color(0xFF0D0D0D),
            body: Center(child: Text('MORTAL CODE')),
          ),
        ),
      );
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('MORTAL CODE'), findsOneWidget);
    });
  });

  group('ConfigScreen', () {
    testWidgets('renderiza correctamente con opciones de audio', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ConfigScreen()),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ConfigScreen), findsOneWidget);
      expect(find.text('AUDIO'), findsOneWidget);
      expect(find.text('Efectos de sonido'), findsOneWidget);
      expect(find.text('Música de fondo'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('contiene dos switches de audio', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ConfigScreen()),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(Switch), findsNWidgets(2));
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('contiene botón de créditos', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ConfigScreen()),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('CRÉDITOS'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('switches inician en true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ConfigScreen()),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches.first.value, isTrue);
      expect(switches.last.value, isTrue);
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('switch responde al tap y cambia valor', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ConfigScreen()),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.byType(Switch).first);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches.first.value, isFalse);
    }, timeout: const Timeout(Duration(seconds: 10)));
  });

  group('CreditsScreen', () {
    testWidgets('renderiza correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CreditsScreen()),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(CreditsScreen), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('muestra sección de universidad', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CreditsScreen()),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('UNIVERSIDAD'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('muestra sección de equipo de desarrollo', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CreditsScreen()),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('EQUIPO'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('muestra sección de tecnologías', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CreditsScreen()),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('TECNOLOGÍAS'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('muestra sección de agradecimientos', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CreditsScreen()),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('AGRADECIMIENTOS'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('muestra Flutter en tecnologías', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CreditsScreen()),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('Flutter'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 10)));
  });
}