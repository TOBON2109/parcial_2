import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../models/establecimiento.dart';
import '../../services/establecimiento_service.dart';

class ListaView extends StatefulWidget {
  const ListaView({super.key});
  @override
  State<ListaView> createState() => _ListaViewState();
}

class _ListaViewState extends State<ListaView> {
  bool _loading = true;
  String? _error;
  List<Establecimiento> _lista = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await EstablecimientoService().obtenerTodos();
      setState(() {
        _lista = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Establecimientos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.pushNamed('crear');
          _cargar();
        },
        child: const Icon(Icons.add),
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!),
                  ElevatedButton(
                    onPressed: _cargar,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : Skeletonizer(
              enabled: _loading,
              child: ListView.builder(
                itemCount: _loading ? 6 : _lista.length,
                itemBuilder: (ctx, i) {
                  final e = _loading
                      ? Establecimiento(
                          id: 0,
                          nombre: 'Cargando...',
                          nit: '0000',
                          direccion: '---',
                          telefono: '---',
                        )
                      : _lista[i];
                  return ListTile(
                    leading: e.logo != null
                        ? Image.network(
                            e.logo!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.store),
                          )
                        : const Icon(Icons.store, size: 48),
                    title: Text(e.nombre),
                    subtitle: Text(
                      'NIT: ${e.nit}\n${e.direccion}\n${e.telefono}',
                    ),
                    isThreeLine: true,
                    onTap: () async {
                      await context.pushNamed(
                        'detalle',
                        pathParameters: {'id': '${e.id}'},
                      );
                      _cargar();
                    },
                  );
                },
              ),
            ),
    );
  }
}
