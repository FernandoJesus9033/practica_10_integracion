import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notificaciones {
  static final plugin = FlutterLocalNotificationsPlugin();

  static Future<void> iniciar() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    // Inicialización correcta
    await plugin.initialize(settings: settings);
  }

  static Future<void> mostrar(String titulo) async {
    const detalles = NotificationDetails(
      android: AndroidNotificationDetails(
        'canal_practica',
        'Práctica móvil',
        channelDescription: 'Alertas de la aplicación',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    // Sintaxis con nombres de parámetros (obligatorio en versiones nuevas)
    await plugin.show(
      id: 1,
      title: 'Nuevo Reporte',
      body: 'Se ha guardado: $titulo',
      notificationDetails: detalles,
    );
  }
}
