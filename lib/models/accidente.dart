class Accidente {
  final String claseDeAccidente;
  final String gravedadDelAccidente;
  final String barrioHecho;
  final String dia;
  final String hora;
  final String area;
  final String claseDeVehiculo;

  Accidente({
    required this.claseDeAccidente,
    required this.gravedadDelAccidente,
    required this.barrioHecho,
    required this.dia,
    required this.hora,
    required this.area,
    required this.claseDeVehiculo,
  });

  factory Accidente.fromJson(Map<String, dynamic> json) {
    return Accidente(
      claseDeAccidente: json['clase_de_accidente'] ?? 'Sin datos',
      gravedadDelAccidente: json['gravedad_del_accidente'] ?? 'Sin datos',
      barrioHecho: json['barrio_hecho'] ?? 'Sin datos',
      dia: json['dia'] ?? 'Sin datos',
      hora: json['hora'] ?? '',
      area: json['area'] ?? '',
      claseDeVehiculo: json['clase_de_vehiculo'] ?? '',
    );
  }
}
