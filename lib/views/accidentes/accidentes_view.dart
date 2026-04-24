import 'dart:isolate';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
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
    try {
      final accidentes = await AccidenteService().obtenerTodos();
      final stats = await Isolate.run(() => calcularEstadisticas(accidentes));
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
        body: Center(child: Text('Error: $_error')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas de Accidentes')),
      body: Skeletonizer(
        enabled: _loading,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _titulo('Distribución por Clase'),
            SizedBox(height: 200, child: _loading ? _fakePie() : _pieClase()),
            const SizedBox(height: 24),
            _titulo('Distribución por Gravedad'),
            SizedBox(
              height: 200,
              child: _loading ? _fakePie() : _pieGravedad(),
            ),
            const SizedBox(height: 24),
            _titulo('Top 5 Barrios con más Accidentes'),
            SizedBox(height: 250, child: _loading ? _fakeBar() : _barBarrios()),
            const SizedBox(height: 24),
            _titulo('Accidentes por Día de la Semana'),
            SizedBox(height: 250, child: _loading ? _fakeBar() : _barDias()),
          ],
        ),
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

  Widget _fakePie() => const Center(child: CircularProgressIndicator());
  Widget _fakeBar() => const Center(child: CircularProgressIndicator());

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
                titleStyle: const TextStyle(fontSize: 10),
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
                titleStyle: const TextStyle(fontSize: 10),
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
                  ),
                ],
              ),
            )
            .toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (v, m) => Transform.rotate(
                angle: -0.5,
                child: Text(
                  lista[v.toInt()]['barrio'].toString().substring(0, 6),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
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
              getTitlesWidget: (v, m) => Text(
                dias[v.toInt()].substring(0, 3),
                style: const TextStyle(fontSize: 10),
              ),
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
