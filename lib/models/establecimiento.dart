class Establecimiento {
  final int id;
  final String nombre;
  final String nit;
  final String direccion;
  final String telefono;
  final String? logo;

  Establecimiento({
    required this.id,
    required this.nombre,
    required this.nit,
    required this.direccion,
    required this.telefono,
    this.logo,
  });

  factory Establecimiento.fromJson(Map<String, dynamic> json) {
    return Establecimiento(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      nit: json['nit'] ?? '',
      direccion: json['direccion'] ?? '',
      telefono: json['telefono'] ?? '',
      logo: json['logo'],
    );
  }
}
