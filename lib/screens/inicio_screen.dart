import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../models/reporte.dart';
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
  final descCtrl = TextEditingController();
  String categoria = 'Mantenimiento';
  XFile? foto;
  Position? posicion;
  bool cargando = false;

  Future<void> obtenerDatos() async {
    setState(() => cargando = true);
    try {
      final f = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50);
      if (f != null) {
        setState(() => foto = f);
      }

      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('GPS desactivado');
      }
      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied || permiso == LocationPermission.deniedForever) {
        throw Exception('Permiso denegado');
      }
      final p = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() => posicion = p);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => cargando = false);
      }
    }
  }

  Future<void> guardar() async {
    if (formKey.currentState!.validate()) {
      if (foto == null || posicion == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, captura foto y ubicación primero')));
        return;
      }
      setState(() => cargando = true);

      final reporte = Reporte(
        titulo: tituloCtrl.text,
        descripcion: descCtrl.text,
        categoria: categoria,
        fotoPath: foto!.path,
        latitud: posicion!.latitude,
        longitud: posicion!.longitude,
        fechaHora: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
      );

      await DBService.insertar(reporte);
      await Notificaciones.mostrar(tituloCtrl.text);

      tituloCtrl.clear();
      descCtrl.clear();
      
      if (mounted) {
        setState(() {
          foto = null;
          posicion = null;
          cargando = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reporte guardado con éxito')));
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ListaScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte Móvil de Incidencias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ListaScreen())),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: tituloCtrl,
                decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Ingresa un título' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Ingresa una descripción' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: categoria,
                decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                items: ['Mantenimiento', 'Limpieza', 'Seguridad', 'Otro']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => categoria = v!),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: obtenerDatos,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Capturar Foto y GPS'),
                    ),
                  ),
                ],
              ),
              if (foto != null) ...[
                const SizedBox(height: 10),
                Image.file(File(foto!.path), height: 150),
              ],
              if (posicion != null) ...[
                const SizedBox(height: 10),
                Text('Lat: ${posicion!.latitude}, Lon: ${posicion!.longitude}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: cargando ? null : guardar,
                  icon: cargando ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
                  label: const Text('Guardar Reporte'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}