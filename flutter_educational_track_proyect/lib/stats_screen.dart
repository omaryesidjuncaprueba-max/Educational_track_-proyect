import 'package:flutter/material.dart';
import 'api_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarStats();
  }

  Future<void> _cargarStats() async {
    final data = await _api.getEstadisticas();
    setState(() {
      _stats = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas'), backgroundColor: const Color(0xFF1E3A8A)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _tarjeta('Total proyectos', _stats['total'] ?? 0, Icons.production_quantity_limits),
                  _tarjeta('Pendientes', _stats['pendientes'] ?? 0, Icons.pending_actions, Colors.orange),
                  _tarjeta('Aprobados', _stats['aprobados'] ?? 0, Icons.check_circle, Colors.green),
                  _tarjeta('Rechazados', _stats['rechazados'] ?? 0, Icons.cancel, Colors.red),
                  const SizedBox(height: 20),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.star, color: Colors.amber, size: 40),
                      title: const Text('Calificación promedio'),
                      subtitle: Text(_stats['promedio']?.toString() ?? '0.0'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _tarjeta(String titulo, int valor, IconData icon, [Color? color]) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 40, color: color ?? Colors.blue),
        title: Text(titulo, style: const TextStyle(fontSize: 18)),
        trailing: Text(valor.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }
}