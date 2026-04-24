import '../models/accidente.dart';

Map<String, dynamic> calcularEstadisticas(List<Accidente> accidentes) {
  final inicio = DateTime.now();
  print('[Isolate] Iniciado — ${accidentes.length} registros recibidos');

  // 1. Distribución por clase de accidente
  final Map<String, int> porClase = {};
  // 2. Distribución por gravedad
  final Map<String, int> porGravedad = {};
  // 3. Top barrios
  final Map<String, int> porBarrio = {};
  // 4. Por día de la semana
  final Map<String, int> porDia = {};

  for (final a in accidentes) {
    porClase[a.claseDeAccidente] = (porClase[a.claseDeAccidente] ?? 0) + 1;
    porGravedad[a.gravedadDelAccidente] =
        (porGravedad[a.gravedadDelAccidente] ?? 0) + 1;
    porBarrio[a.barrioHecho] = (porBarrio[a.barrioHecho] ?? 0) + 1;
    porDia[a.dia] = (porDia[a.dia] ?? 0) + 1;
  }

  // Top 5 barrios
  final topBarrios =
      (porBarrio.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
          .take(5)
          .map((e) => {'barrio': e.key, 'total': e.value})
          .toList();

  final ms = DateTime.now().difference(inicio).inMilliseconds;
  print('[Isolate] Completado en $ms ms');

  return {
    'porClase': porClase,
    'porGravedad': porGravedad,
    'topBarrios': topBarrios,
    'porDia': porDia,
  };
}
