import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/establecimiento.dart';
import '../../services/establecimiento_service.dart';

class FormularioView extends StatefulWidget {
  const FormularioView({super.key});
  @override
  State<FormularioView> createState() => _FormularioViewState();
}

class _FormularioViewState extends State<FormularioView> {
  final _nombre = TextEditingController();
  final _nit = TextEditingController();
  final _direccion = TextEditingController();
  final _telefono = TextEditingController();
  File? _imagen;
  bool _guardando = false;
  Establecimiento? _est;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is Establecimiento && _est == null) {
      _est = extra;
      _nombre.text = extra.nombre;
      _nit.text = extra.nit;
      _direccion.text = extra.direccion;
      _telefono.text = extra.telefono;
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imagen = File(picked.path));
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      final fields = {
        'nombre': _nombre.text,
        'nit': _nit.text,
        'direccion': _direccion.text,
        'telefono': _telefono.text,
      };
      final form = FormData.fromMap(fields);
      if (_imagen != null) {
        form.files.add(
          MapEntry(
            'logo',
            await MultipartFile.fromFile(_imagen!.path, filename: 'logo.jpg'),
          ),
        );
      }
      if (_est == null) {
        await EstablecimientoService().crear(form);
      } else {
        await EstablecimientoService().editar(_est!.id, form);
      }
      if (mounted) context.pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _est == null ? 'Crear Establecimiento' : 'Editar Establecimiento',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _imagen != null
                    ? Image.file(_imagen!, fit: BoxFit.cover)
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                          Text(
                            'Seleccionar logo',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nombre,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _nit,
              decoration: const InputDecoration(labelText: 'NIT'),
            ),
            TextField(
              controller: _direccion,
              decoration: const InputDecoration(labelText: 'Dirección'),
            ),
            TextField(
              controller: _telefono,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const CircularProgressIndicator()
                    : const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
