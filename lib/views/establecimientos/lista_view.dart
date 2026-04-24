import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
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
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _cargar,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : _loading
          ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (_, __) => ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    color: Colors.white,
                  ),
                  title: Container(height: 12, color: Colors.white),
                  subtitle: Container(height: 10, color: Colors.white),
                ),
              ),
            )
          : ListView.builder(
              itemCount: _lista.length,
              itemBuilder: (ctx, i) {
                final e = _lista[i];
                return ListTile(
                  leading: e.logo != null
                      ? Image.network(
                          e.logo!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.store, size: 48),
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
    );
  }
}
