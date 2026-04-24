import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/establecimiento.dart';
import '../../services/establecimiento_service.dart';

class DetalleView extends StatefulWidget {
  final String id;
  const DetalleView({super.key, required this.id});
  @override
  State<DetalleView> createState() => _DetalleViewState();
}

class _DetalleViewState extends State<DetalleView> {
  Establecimiento? _est;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final e = await EstablecimientoService().obtenerPorId(int.parse(widget.id));
    setState(() {
      _est = e;
      _loading = false;
    });
  }

  Future<void> _eliminar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await EstablecimientoService().eliminar(int.parse(widget.id));
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await context.pushNamed('crear', extra: _est);
              _cargar();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _eliminar,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _est == null
          ? const Center(child: Text('No encontrado'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_est!.logo != null)
                    Center(child: Image.network(_est!.logo!, height: 120)),
                  const SizedBox(height: 16),
                  _campo('Nombre', _est!.nombre),
                  _campo('NIT', _est!.nit),
                  _campo('Dirección', _est!.direccion),
                  _campo('Teléfono', _est!.telefono),
                ],
              ),
            ),
    );
  }

  Widget _campo(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    ),
  );
}
