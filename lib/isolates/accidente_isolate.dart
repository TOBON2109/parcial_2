Map<String, dynamic> calcularEstadisticas(List<Map<String, dynamic>> datos) {
  final inicio = DateTime.now();
  print('[Isolate] Iniciado — ${datos.length} registros recibidos');

  final Map<String, int> porClase = {};
  final Map<String, int> porGravedad = {};
  final Map<String, int> porBarrio = {};
  final Map<String, int> porDia = {};

  for (final a in datos) {
    final clase = a['clase_de_accidente']?.toString() ?? 'Sin datos';
    final gravedad = a['gravedad_del_accidente']?.toString() ?? 'Sin datos';
    final barrio = a['barrio_hecho']?.toString() ?? 'Sin datos';
    final dia = a['dia']?.toString() ?? 'Sin datos';

    porClase[clase] = (porClase[clase] ?? 0) + 1;
    porGravedad[gravedad] = (porGravedad[gravedad] ?? 0) + 1;
    porBarrio[barrio] = (porBarrio[barrio] ?? 0) + 1;
    porDia[dia] = (porDia[dia] ?? 0) + 1;
  }

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
