import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/accidente_service.dart';
import '../../services/establecimiento_service.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});
  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool _loading = true;
  int _totalAccidentes = 0;
  int _totalEstablecimientos = 0;

  @override
  void initState() {
    super.initState();
    _cargarTotales();
  }

  Future<void> _cargarTotales() async {
    try {
      final acc = await AccidenteService().obtenerTotal();
      final est = await EstablecimientoService().obtenerTodos();
      setState(() {
        _totalAccidentes = acc;
        _totalEstablecimientos = est.length;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Principal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _loading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Row(
                      children: [
                        Expanded(child: Card(child: SizedBox(height: 80))),
                        const SizedBox(width: 12),
                        Expanded(child: Card(child: SizedBox(height: 80))),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      _statCard(
                        'Accidentes',
                        '$_totalAccidentes',
                        Icons.warning_amber,
                      ),
                      const SizedBox(width: 12),
                      _statCard(
                        'Establecimientos',
                        '$_totalEstablecimientos',
                        Icons.store,
                      ),
                    ],
                  ),
            const SizedBox(height: 24),
            _menuCard(
              'Estadísticas de Accidentes',
              Icons.bar_chart,
              () => context.pushNamed('accidentes'),
            ),
            const SizedBox(height: 12),
            _menuCard(
              'Gestión de Establecimientos',
              Icons.store,
              () => context.pushNamed('establecimientos'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
