class Reporte {
  final int? id;
  final String titulo;
  final String descripcion;
  final String categoria;
  final String fotoPath;
  final double latitud;
  final double longitud;
  final String fechaHora;

  Reporte({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.fotoPath,
    required this.latitud,
    required this.longitud,
    required this.fechaHora,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'titulo': titulo,
    'descripcion': descripcion,
    'categoria': categoria,
    'fotoPath': fotoPath,
    'latitud': latitud,
    'longitud': longitud,
    'fechaHora': fechaHora,
  };

  factory Reporte.fromMap(Map<String, dynamic> map) => Reporte(
    id: map['id'],
    titulo: map['titulo'],
    descripcion: map['descripcion'],
    categoria: map['categoria'],
    fotoPath: map['fotoPath'],
    latitud: map['latitud'],
    longitud: map['longitud'],
    fechaHora: map['fechaHora'],
  );
}
