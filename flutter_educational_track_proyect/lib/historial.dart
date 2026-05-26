class Historial {
  final int id;
  final int proyectoId;
  final String usuarioNombre;
  final double? nota;
  final String estado;
  final String comentario;
  final DateTime fecha;

  Historial({
    required this.id,
    required this.proyectoId,
    required this.usuarioNombre,
    this.nota,
    required this.estado,
    required this.comentario,
    required this.fecha,
  });

  factory Historial.fromJson(Map<String, dynamic> json) {
    return Historial(
      id: json['id'],
      proyectoId: json['proyecto'],
      usuarioNombre: json['usuario_nombre'] ?? '',
      nota: json['nota']?.toDouble(),
      estado: json['estado'],
      comentario: json['comentario'] ?? '',
      fecha: DateTime.parse(json['fecha']),
    );
  }
}