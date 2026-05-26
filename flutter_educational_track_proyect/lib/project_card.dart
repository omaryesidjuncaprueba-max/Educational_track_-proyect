import 'package:flutter/material.dart';
import 'project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final bool canCalificar;
  final VoidCallback? onCalificar;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.canCalificar,
    this.onCalificar,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = project.estado == 'aprobado';
    final isPending = project.estado == 'pendiente';
    final statusText = isApproved ? 'APROBADO' : (isPending ? 'PENDIENTE' : 'RECHAZADO');
    final statusColor = isApproved ? Colors.green.shade800 : (isPending ? Colors.orange.shade800 : Colors.red.shade800);
    final statusBg = isApproved ? Colors.green.shade50 : (isPending ? Colors.orange.shade50 : Colors.red.shade50);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Autores: ${project.autoresNombres.join(', ')}', style: const TextStyle(color: Colors.blue, fontSize: 11)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                  child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(project.titulo, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(project.descripcion, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 15),
            if (project.calificacion != null) Text('Nota: ${project.calificacion}'),
            if (project.comentarioRevision != null && project.comentarioRevision!.isNotEmpty)
              Text('Comentario: ${project.comentarioRevision}'),
            if (canCalificar && project.estado == 'pendiente') ...[
              const SizedBox(height: 12),
              ElevatedButton(onPressed: onCalificar, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: const Text('Calificar proyecto')),
            ],
          ],
        ),
      ),
    );
  }
}