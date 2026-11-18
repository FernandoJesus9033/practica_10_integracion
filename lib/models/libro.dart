class Libro {
  final int? id;
  final String titulo;
  final String autor;
  final String categoria;
  final String portadaPath;
  final double latitud;
  final double longitud;
  final String fechaRegistro;

  Libro({
    this.id,
    required this.titulo,
    required this.autor,
    required this.categoria,
    required this.portadaPath,
    required this.latitud,
    required this.longitud,
    required this.fechaRegistro,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'titulo': titulo, 'autor': autor, 'categoria': categoria,
    'portadaPath': portadaPath, 'latitud': latitud, 'longitud': longitud, 'fechaRegistro': fechaRegistro,
  };

  factory Libro.fromMap(Map<String, dynamic> map) => Libro(
    id: map['id'], titulo: map['titulo'], autor: map['autor'], categoria: map['categoria'],
    portadaPath: map['portadaPath'], latitud: map['latitud'], longitud: map['longitud'], fechaRegistro: map['fechaRegistro'],
  );
}