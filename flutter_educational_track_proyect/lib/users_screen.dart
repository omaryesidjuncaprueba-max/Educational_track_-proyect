import 'package:flutter/material.dart';
import 'api_service.dart';
import 'user.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final ApiService _api = ApiService();
  List<AppUser> _users = [];
  bool _loading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => _loading = true);
    final data = await _api.fetchUsuariosPaginados(page: _currentPage, pageSize: _pageSize);
    final results = data['results'] as List;
    _users = results.map((j) => AppUser.fromJson(j)).toList();
    _totalPages = (data['count'] / _pageSize).ceil();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios'), backgroundColor: const Color(0xFF1E3A8A)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) => ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(_users[index].username),
                      subtitle: Text(_users[index].rol),
                    ),
                  ),
                ),
                if (_totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _currentPage > 1
                              ? () {
                                  _currentPage--;
                                  _cargarUsuarios();
                                }
                              : null,
                        ),
                        Text('Página $_currentPage de $_totalPages'),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _currentPage < _totalPages
                              ? () {
                                  _currentPage++;
                                  _cargarUsuarios();
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}