import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart'; // compute()
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../isolates/accidente_isolate.dart';
import '../../services/accidente_service.dart';

class AccidentesView extends StatefulWidget {
  const AccidentesView({super.key});
  @override
  State<AccidentesView> createState() => _AccidentesViewState();
}

class _AccidentesViewState extends State<AccidentesView> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _stats = {};

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
      final jsonCrudo = await AccidenteService().obtenerJsonCrudo();
      // compute() es equivalente a Isolate.run() pero compatible con todas las versiones de Flutter
      final stats = await compute(calcularEstadisticas, jsonCrudo);
      setState(() {
        _stats = stats;
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
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Estadísticas')),
        body: Center(
          child: SingleChildScrollView(
            // <-- fix overflow en error
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text('Error: $_error', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _cargar,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas de Accidentes')),
      body: _loading
          ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (_, __) => Container(
                  margin: const EdgeInsets.all(16),
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _titulo('Distribución por Clase de Accidente'),
                SizedBox(height: 220, child: _pieClase()),
                const SizedBox(height: 24),
                _titulo('Distribución por Gravedad'),
                SizedBox(height: 220, child: _pieGravedad()),
                const SizedBox(height: 24),
                _titulo('Top 5 Barrios con más Accidentes'),
                SizedBox(height: 280, child: _barBarrios()),
                const SizedBox(height: 24),
                _titulo('Accidentes por Día de la Semana'),
                SizedBox(height: 280, child: _barDias()),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _titulo(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      t,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );

  Widget _pieClase() {
    final data = (_stats['porClase'] as Map<String, int>? ?? {});
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
    ];
    int i = 0;
    return PieChart(
      PieChartData(
        sections: data.entries
            .map(
              (e) => PieChartSectionData(
                value: e.value.toDouble(),
                title: e.key,
                color: colors[i++ % colors.length],
                radius: 80,
                titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _pieGravedad() {
    final data = (_stats['porGravedad'] as Map<String, int>? ?? {});
    final colors = [Colors.red, Colors.amber, Colors.green];
    int i = 0;
    return PieChart(
      PieChartData(
        sections: data.entries
            .map(
              (e) => PieChartSectionData(
                value: e.value.toDouble(),
                title: '${e.key}\n${e.value}',
                color: colors[i++ % colors.length],
                radius: 80,
                titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _barBarrios() {
    final lista = (_stats['topBarrios'] as List? ?? []);
    return BarChart(
      BarChartData(
        barGroups: lista
            .asMap()
            .entries
            .map(
              (e) => BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: (e.value['total'] as int).toDouble(),
                    color: Colors.indigo,
                    width: 20,
                  ),
                ],
              ),
            )
            .toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (v, m) {
                final idx = v.toInt();
                if (idx < 0 || idx >= lista.length) return const SizedBox();
                final nombre = lista[idx]['barrio'].toString();
                return Transform.rotate(
                  angle: -0.5,
                  child: Text(
                    nombre.length > 8 ? nombre.substring(0, 8) : nombre,
                    style: const TextStyle(fontSize: 9),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
      ),
    );
  }

  Widget _barDias() {
    final data = (_stats['porDia'] as Map<String, int>? ?? {});
    final dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return BarChart(
      BarChartData(
        barGroups: dias
            .asMap()
            .entries
            .map(
              (e) => BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: (data[e.value] ?? 0).toDouble(),
                    color: Colors.teal,
                    width: 20,
                  ),
                ],
              ),
            )
            .toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (v, m) {
                final idx = v.toInt();
                if (idx < 0 || idx >= dias.length) return const SizedBox();
                return Text(
                  dias[idx].substring(0, 3),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
      ),
    );
  }
}
