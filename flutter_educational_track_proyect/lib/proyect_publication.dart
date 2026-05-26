import 'package:flutter/material.dart';
import 'api_service.dart';
import 'project.dart';
import 'project_card.dart';
import 'create_project_screen.dart';
import 'project_detail_screen.dart';
import 'profile_screen.dart';
import 'users_screen.dart';
import 'stats_screen.dart';

class ProyectosScreen extends StatefulWidget {
  final String userRole;
  final String userName;
  const ProyectosScreen({super.key, required this.userRole, required this.userName});

  @override
  State<ProyectosScreen> createState() => _ProyectosScreenState();
}

class _ProyectosScreenState extends State<ProyectosScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Project> _myProjects = [];
  List<Project> _allProjects = [];
  List<Project> _pendingProjects = [];
  bool _loading = true;
  final ApiService _api = ApiService();

  bool get _canReview => widget.userRole == 'lider' || widget.userRole == 'coordinador' || widget.userRole == 'docente';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _canReview ? 3 : 2, vsync: this);
    _loadProjects();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    setState(() => _loading = true);
    final projects = await _api.fetchProjects();
    final currentUser = _api.currentUser;
    if (currentUser != null) {
      _myProjects = projects.where((p) => p.creadoPorNombre == currentUser.username).toList();
      _allProjects = projects;
      _pendingProjects = projects.where((p) => p.estado == 'pendiente').toList();
    } else {
      _myProjects = [];
      _allProjects = [];
      _pendingProjects = [];
    }
    setState(() => _loading = false);
  }

  Future<void> _mostrarDialogoCalificacion(Project proyecto) async {
    double nota = 3.5;
    final comentarioCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Calificar proyecto'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Ingrese una nota (0-5):'),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  onChanged: (value) => nota = double.tryParse(value) ?? 3.5,
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n < 0 || n > 5) return 'Nota entre 0 y 5';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: comentarioCtrl,
                  decoration: const InputDecoration(hintText: 'Comentario (obligatorio si es < 3.5)'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                if (nota < 3.5 && comentarioCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Para rechazar debe escribir un comentario'), backgroundColor: Colors.orange),
                  );
                  return;
                }
                final success = await _api.calificarProyecto(proyecto.id, nota, comentarioCtrl.text.trim());
                if (success) {
                  await _loadProjects();
                  if (mounted) Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(nota >= 3.5 ? 'Proyecto aprobado' : 'Proyecto rechazado')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al calificar'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canReview = _canReview;

    List<Widget> tabViews = [_buildList(_myProjects, canReview)];
    List<Tab> tabs = [const Tab(icon: Icon(Icons.folder_outlined), text: "Mis Proyectos")];
    if (canReview) {
      tabs.add(const Tab(icon: Icon(Icons.pending_actions), text: "Revisar"));
      tabViews.add(_buildList(_pendingProjects, canReview));
    }
    tabs.add(const Tab(icon: Icon(Icons.explore_outlined), text: "Explorar"));
    tabViews.add(_buildList(_allProjects.where((p) => p.estado == 'aprobado').toList(), false));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Educational Track", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E3A8A),
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()))),
          IconButton(icon: const Icon(Icons.people), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UsersScreen()))),
          IconButton(icon: const Icon(Icons.person), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
        ],
        bottom: TabBar(controller: _tabController, tabs: tabs),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Hola, ${widget.userName}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("Rol: ${widget.userRole}", style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w600)),
                ]),
                Icon(_canReview ? Icons.verified_user_rounded : Icons.school_rounded, color: Colors.blueGrey.shade200, size: 38),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(controller: _tabController, children: tabViews),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateProjectScreen()));
          if (result == true) await _loadProjects();
        },
        backgroundColor: const Color(0xFF1E3A8A),
        icon: const Icon(Icons.add),
        label: const Text("Postular Proyecto"),
      ),
    );
  }

  Widget _buildList(List<Project> projects, bool canCalificar) {
    if (projects.isEmpty) {
      return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.inbox_outlined, size: 60, color: Color(0xFFCBD5E1)), SizedBox(height: 16), Text("No hay proyectos")
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final p = projects[index];
        return ProjectCard(
          project: p,
          canCalificar: canCalificar && p.estado == 'pendiente',
          onCalificar: () => _mostrarDialogoCalificacion(p),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: p))),
        );
      },
    );
  }
}