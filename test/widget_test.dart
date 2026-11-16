import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_10_integracion/screens/inicio_screen.dart';

void main() {
  testWidgets('La app carga correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: InicioScreen()));
    expect(find.text('Reporte Móvil de Incidencias'), findsOneWidget);
  });
}