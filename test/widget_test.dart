import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_10_integracion/screens/inicio_screen.dart';

void main() {
  testWidgets('La app de libros carga', (WidgetTester tester) async {
    // Inicializar el widget
    await tester.pumpWidget(const MaterialApp(home: InicioScreen()));
    
    // Verificar que el título de la AppBar sea el del ejercicio evaluable
    expect(find.text('Registro de Libros'), findsOneWidget);
  });
}