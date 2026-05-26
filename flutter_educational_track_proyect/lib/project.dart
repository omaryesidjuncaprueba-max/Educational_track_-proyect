class Project {
  final int id;
  final String titulo;
  final String descripcion;
  final String estado;
  final double? calificacion;
  final String creadoPorNombre;
  final List<String> autoresNombres;
  final String? comentarioRevision;
  final String? tipo;        // nuevo
  final String? categoria;   // nuevo

  Project({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.estado,
    this.calificacion,
    required this.creadoPorNombre,
    required this.autoresNombres,
    this.comentarioRevision,
    this.tipo,
    this.categoria,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      estado: json['estado'],
      calificacion: json['calificacion']?.toDouble(),
      creadoPorNombre: json['creado_por_nombre'] ?? '',
      autoresNombres: (json['autores_nombres'] as List?)?.cast<String>() ?? [],
      comentarioRevision: json['comentario_revision'],
      tipo: json['tipo'],
      categoria: json['categoria'],
    );
  }
}