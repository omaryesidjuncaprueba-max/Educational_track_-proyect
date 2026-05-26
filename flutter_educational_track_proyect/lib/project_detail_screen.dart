import 'package:flutter/material.dart';
import 'project.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;
  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  // Aquí podrías cargar historial real desde ApiService
  // List<Historial> _historial = [];

  @override
  void initState() {
    super.initState();
    // _cargarHistorial();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return Scaffold(
      appBar: AppBar(title: Text(p.titulo), backgroundColor: const Color(0xFF1E3A8A)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height: 8), Text(p.descripcion),
            const SizedBox(height: 16), Text('Estado: ${p.estado}'),
            const SizedBox(height: 8), Text('Nota: ${p.calificacion ?? "No calificado"}'),
            const SizedBox(height: 8), Text('Autores: ${p.autoresNombres.join(", ")}'),
            if (p.comentarioRevision != null && p.comentarioRevision!.isNotEmpty) ...[
              const SizedBox(height: 16), Text('Comentario:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(p.comentarioRevision!),
            ],
            const Divider(height: 40),
            const Text('Historial por semestre', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            // TODO: Conectar con backend para mostrar historial real.
            // Por ahora, simulación:
            Card(
              child: ListTile(
                title: const Text('Semestre 2025-1'),
                subtitle: const Text('Proyecto creado • Pendiente'),
                trailing: const Icon(Icons.history),
                onTap: () {},
              ),
            ),
            const Text('(Próximamente historial completo de cambios, calificaciones y comentarios)'),
          ],
        ),
      ),
    );
  }
}