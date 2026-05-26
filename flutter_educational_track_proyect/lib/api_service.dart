import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user.dart';
import 'project.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String baseUrl = 'http://localhost:8000/api';
  final http.Client _client = http.Client();
  String? _token;
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  // ================= LOGIN (con token) =================
  Future<Map<String, dynamic>?> login(String usernameOrEmail, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/token/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': usernameOrEmail, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = AppUser.fromJson(data);
        return data;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Headers con token de autenticación
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Token $_token',
    };
  }

  // ================= REGISTRO =================
  Future<bool> register({required String username, required String email, required String password}) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'email': email, 'password': password}),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  // ================= USUARIOS (sin paginación) =================
  Future<List<AppUser>> getUsers() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/usuarios/'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => AppUser.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('GetUsers error: $e');
      return [];
    }
  }

  // ================= USUARIOS CON PAGINACIÓN =================
  Future<Map<String, dynamic>> fetchUsuariosPaginados({int page = 1, int pageSize = 10}) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/usuarios/paginados/?page=$page&page_size=$pageSize'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'results': [], 'count': 0};
    } catch (e) {
      print('fetchUsuariosPaginados error: $e');
      return {'results': [], 'count': 0};
    }
  }

  // ================= PROYECTOS (sin paginación) =================
  Future<List<Project>> fetchProjects() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/proyectos/'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Project.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('FetchProjects error: $e');
      return [];
    }
  }

  // ================= PROYECTOS CON PAGINACIÓN =================
  Future<Map<String, dynamic>> fetchProyectosPaginados({int page = 1, int pageSize = 10}) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/proyectos/paginados/?page=$page&page_size=$pageSize'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'results': [], 'count': 0};
    } catch (e) {
      print('fetchProyectosPaginados error: $e');
      return {'results': [], 'count': 0};
    }
  }

  // ================= CREAR PROYECTO =================
  Future<bool> createProject({
    required String titulo,
    required String descripcion,
    required List<String> autores,
    required String tipo,
    required String categoria,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/proyectos/'),
        headers: _getHeaders(),
        body: jsonEncode({
          'titulo': titulo,
          'descripcion': descripcion,
          'autores': autores,
          'tipo': tipo,
          'categoria': categoria,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('CreateProject error: $e');
      return false;
    }
  }

  // ================= CALIFICAR PROYECTO (aprueba o rechaza según nota) =================
  Future<bool> calificarProyecto(int projectId, double nota, String comentario) async {
    final estado = nota >= 3.5 ? 'aprobado' : 'rechazado';
    try {
      final response = await _client.patch(
        Uri.parse('$baseUrl/proyectos/$projectId/calificar/'),
        headers: _getHeaders(),
        body: jsonEncode({
          'estado': estado,
          'calificacion': nota,
          'comentario_revision': comentario,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('calificarProyecto error: $e');
      return false;
    }
  }

  // ================= HISTORIAL DEL PROYECTO =================
  Future<List<Map<String, dynamic>>> getHistorialProyecto(int projectId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/proyectos/$projectId/historial/'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      print('getHistorialProyecto error: $e');
      return [];
    }
  }

  // ================= ESTADÍSTICAS =================
  Future<Map<String, dynamic>> getEstadisticas() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/estadisticas/'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {};
    } catch (e) {
      print('getEstadisticas error: $e');
      return {};
    }
  }

  // ================= EDITAR PERFIL =================
  Future<bool> editarPerfil({
    String? nombreCompleto,
    String? telefono,
    String? email,
    String? nuevaPassword,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (nombreCompleto != null) body['nombre_completo'] = nombreCompleto;
      if (telefono != null) body['telefono'] = telefono;
      if (email != null) body['email'] = email;
      if (nuevaPassword != null) body['nueva_password'] = nuevaPassword;
      final response = await _client.put(
        Uri.parse('$baseUrl/editar-perfil/'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = AppUser.fromJson(data);
        return true;
      }
      return false;
    } catch (e) {
      print('editarPerfil error: $e');
      return false;
    }
  }

  // ================= LOGOUT =================
  void logout() {
    _token = null;
    _currentUser = null;
    // No cerramos _client para permitir futuros logins
  }
}