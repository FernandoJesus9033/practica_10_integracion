import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/libro.dart';
import '../services/db_service.dart';

class ListaScreen extends StatefulWidget {
  const ListaScreen({super.key});
  @override
  State<ListaScreen> createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {
  late Future<List<Libro>> _librosFuture;
  String _tipApi = 'Cargando datos de la API...';

  @override
  void initState() {
    super.initState();
    _librosFuture = DBService.listar();
    _cargarApi();
  }

  Future<void> _cargarApi() async {
    try {
      final r = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/2'));
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        setState(() => _tipApi = data['title']);
      }
    } catch (_) {
      setState(() => _tipApi = 'Error al cargar API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de Libros')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16), color: Colors.blue[50], width: double.infinity,
            child: Text('Dato Curioso (API):\n$_tipApi', style: const TextStyle(fontStyle: FontStyle.italic)),
          ),
          Expanded(
            child: FutureBuilder<List<Libro>>(
              future: _librosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final libros = snapshot.data ?? [];
                if (libros.isEmpty) return const Center(child: Text('No hay libros registrados'));
                return ListView.builder(
                  itemCount: libros.length,
                  itemBuilder: (_, i) {
                    final l = libros[i];
                    return Card(
                      child: ListTile(
                        leading: Image.file(File(l.portadaPath), width: 50, height: 50, fit: BoxFit.cover),
                        title: Text(l.titulo), subtitle: Text('${l.autor} | ${l.categoria}'),
                        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
                          await DBService.eliminar(l.id!);
                          setState(() => _librosFuture = DBService.listar());
                        }),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}