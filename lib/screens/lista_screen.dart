import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/reporte.dart';
import '../services/db_service.dart';

class ListaScreen extends StatefulWidget {
  const ListaScreen({super.key});

  @override
  State<ListaScreen> createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {
  late Future<List<Reporte>> _reportesFuture;
  String _tipApi = 'Cargando datos de la API...';

  @override
  void initState() {
    super.initState();
    _reportesFuture = DBService.listar();
    _cargarApi();
  }

  Future<void> _cargarApi() async {
    try {
      final r = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        if (mounted) {
          setState(() => _tipApi = data['title']);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _tipApi = 'Error al cargar API');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes Guardados')),
      body: Column(
        children: [
          // Sección API
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.purple[50],
            width: double.infinity,
            child: Text('Tip del día (API):\n$_tipApi'),
          ),
          const Divider(),
          
          // Sección Lista SQLite
          Expanded(
            child: FutureBuilder<List<Reporte>>(
              future: _reportesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final reportes = snapshot.data ?? [];
                if (reportes.isEmpty) return const Center(child: Text('No hay reportes guardados'));

                return ListView.builder(
                  itemCount: reportes.length,
                  itemBuilder: (_, i) {
                    final r = reportes[i];
                    return Card(
                      child: ListTile(
                        leading: Image.file(File(r.fotoPath), width: 50, height: 50, fit: BoxFit.cover),
                        title: Text(r.titulo),
                        subtitle: Text('${r.categoria} | ${r.fechaHora}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await DBService.eliminar(r.id!);
                            if (mounted) {
                              setState(() {
                                _reportesFuture = DBService.listar();
                              });
                            }
                          },
                        ),
                        onTap: () => showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(r.titulo),
                            content: Text('${r.descripcion}\n\nLat: ${r.latitud}\nLon: ${r.longitud}'),
                          ),
                        ),
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