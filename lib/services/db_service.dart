import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/reporte.dart';

class DBService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final ruta = join(await getDatabasesPath(), 'reportes.db');
    _db = await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) => db.execute(
        'CREATE TABLE reportes(id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT, descripcion TEXT, categoria TEXT, fotoPath TEXT, latitud REAL, longitud REAL, fechaHora TEXT)',
      ),
    );
    return _db!;
  }

  static Future<int> insertar(Reporte r) async {
    final db = await database;
    return db.insert('reportes', r.toMap());
  }

  static Future<List<Reporte>> listar() async {
    final db = await database;
    final data = await db.query('reportes', orderBy: 'id DESC');
    return data.map((e) => Reporte.fromMap(e)).toList();
  }

  static Future<int> eliminar(int id) async {
    final db = await database;
    return db.delete('reportes', where: 'id = ?', whereArgs: [id]);
  }
}
