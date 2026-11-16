import 'package:flutter/material.dart';

import 'screens/inicio_screen.dart';
import 'services/notificaciones_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notificaciones.iniciar();
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: InicioScreen()),
  );
}
