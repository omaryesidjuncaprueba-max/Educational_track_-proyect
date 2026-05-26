class AppUser {
  final int id;
  final String username;
  final String email;
  final String rol;
  final String? nombreCompleto;
  final String? telefono;

  AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.rol,
    this.nombreCompleto,
    this.telefono,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      username: json['username'],
      email: json['email'] ?? json['username'],
      rol: json['rol'] ?? 'usuario_general',
      nombreCompleto: json['nombre_completo'],
      telefono: json['telefono'],
    );
  }
}