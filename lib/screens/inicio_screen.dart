import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../models/libro.dart';
import '../services/db_service.dart';
import '../services/notificaciones_service.dart';
import 'lista_screen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});
  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final formKey = GlobalKey<FormState>();
  final tituloCtrl = TextEditingController();
  final autorCtrl = TextEditingController();
  String categoria = 'Novela';
  XFile? foto;
  Position? posicion;
  bool cargando = false;

  Future<void> obtenerDatos() async {
    setState(() => cargando = true);
    try {
      final f = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50);
      if (f != null) setState(() => foto = f);
      final p = await Geolocator.getCurrentPosition();
      setState(() => posicion = p);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => cargando = false);
    }
  }

  Future<void> guardar() async {
    if (formKey.currentState!.validate() && foto != null && posicion != null) {
      setState(() => cargando = true);
      final libro = Libro(
        titulo: tituloCtrl.text, autor: autorCtrl.text, categoria: categoria,
        portadaPath: foto!.path, latitud: posicion!.latitude, longitud: posicion!.longitude,
        fechaRegistro: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
      );
      await DBService.insertar(libro);
      await Notificaciones.mostrar(libro.titulo);
      
      tituloCtrl.clear(); autorCtrl.clear();
      setState(() { foto = null; posicion = null; cargando = false; });
      if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const ListaScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa todos los campos')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Libros'), actions: [
        IconButton(icon: const Icon(Icons.list), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ListaScreen())))
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(controller: tituloCtrl, decoration: const InputDecoration(labelText: 'Título del Libro', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 10),
              TextFormField(controller: autorCtrl, decoration: const InputDecoration(labelText: 'Autor', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: categoria, decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                items: ['Novela', 'Ciencia', 'Historia', 'Tecnología'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => categoria = v!),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(onPressed: obtenerDatos, icon: const Icon(Icons.camera_alt), label: const Text('Portada y Ubicación')),
              if (foto != null) Image.file(File(foto!.path), height: 150),
              if (posicion != null) Text('Lat: ${posicion!.latitude}'),
              const SizedBox(height: 20),
              FilledButton(onPressed: cargando ? null : guardar, child: const Text('Guardar Libro')),
            ],
          ),
        ),
      ),
    );
  }
}