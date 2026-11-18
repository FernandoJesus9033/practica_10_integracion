import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/libro.dart';

class DBService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final ruta = join(await getDatabasesPath(), 'libros.db');
    _db = await openDatabase(
      ruta, version: 1,
      onCreate: (db, version) => db.execute(
        'CREATE TABLE libros(id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT, autor TEXT, categoria TEXT, portadaPath TEXT, latitud REAL, longitud REAL, fechaRegistro TEXT)',
      ),
    );
    return _db!;
  }

  static Future<int> insertar(Libro r) async {
    final db = await database;
    return db.insert('libros', r.toMap());
  }

  static Future<List<Libro>> listar() async {
    final db = await database;
    final data = await db.query('libros', orderBy: 'id DESC');
    return data.map((e) => Libro.fromMap(e)).toList();
  }

  static Future<int> eliminar(int id) async {
    final db = await database;
    return db.delete('libros', where: 'id = ?', whereArgs: [id]);
  }
}