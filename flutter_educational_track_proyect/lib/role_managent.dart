import 'package:flutter/material.dart';

// ── Modelo simple de usuario ──────────────────────────────────────────────────
class AppUser {
  final String id;
  final String name;
  final String email;
  String role;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}

// ── Roles disponibles ─────────────────────────────────────────────────────────
const List<String> kRoles = [
  'Administrador',
  'Coordinador',
  'Usuario General',
];

const Map<String, IconData> kRoleIcons = {
  'Administrador': Icons.admin_panel_settings_outlined,
  'Coordinador': Icons.manage_accounts_outlined,
  'Usuario General': Icons.person_outline,
};

const Map<String, Color> kRoleColors = {
  'Administrador': Color(0xFF7C3AED),
  'Coordinador': Color(0xFF2563EB),
  'Usuario General': Color(0xFF0891B2),
};

// ── Datos de prueba con dominio institucional ─────────────────────────────────
final List<AppUser> _mockUsers = [
  AppUser(id: '1', name: 'Ana García',     email: 'ana.garcia@ucundinamarca.edu.co',      role: 'Coordinador'),
  AppUser(id: '2', name: 'Carlos Ruiz',    email: 'carlos.ruiz@ucundinamarca.edu.co',     role: 'Usuario General'),
  AppUser(id: '3', name: 'María López',    email: 'maria.lopez@ucundinamarca.edu.co',     role: 'Usuario General'),
  AppUser(id: '4', name: 'Pedro Martínez', email: 'pedro.martinez@ucundinamarca.edu.co',  role: 'Coordinador'),
  AppUser(id: '5', name: 'Sofía Torres',   email: 'sofia.torres@ucundinamarca.edu.co',    role: 'Usuario General'),
];

// ─────────────────────────────────────────────────────────────────────────────
class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen>
    with SingleTickerProviderStateMixin {
  final List<AppUser> _users = List.from(_mockUsers);
  String _search = '';
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  List<AppUser> get _filtered => _users
      .where((u) =>
          u.name.toLowerCase().contains(_search.toLowerCase()) ||
          u.email.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  // ── Asignar / modificar rol ───────────────────────────────────────────────
  void _showRoleDialog(AppUser user, {bool isNew = false}) {
    String selected = user.role;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isNew ? 'Asignar rol' : 'Modificar rol',
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: Color(0xFF1E3A8A)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF334155))),
              Text(user.email,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF64748B))),
              const SizedBox(height: 20),
              ...kRoles.map((r) {
                final color = kRoleColors[r]!;
                final isSelected = selected == r;
                return GestureDetector(
                  onTap: () => setS(() => selected = r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.12)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(kRoleIcons[r], color: color, size: 20),
                        const SizedBox(width: 12),
                        Text(r,
                            style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? color
                                    : const Color(0xFF475569))),
                        const Spacer(),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded,
                              color: color, size: 18),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar',
                  style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () {
                setState(() => user.role = selected);
                Navigator.pop(ctx);
                _showNotification(
                    '✅ Rol actualizado: ${user.name} → $selected');
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      }),
    );
  }

  // ── Eliminar rol (vuelve a Usuario General) ───────────────────────────────
  void _confirmDelete(AppUser user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar rol',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
        content: Text(
          '¿Deseas quitar el rol de "${user.role}" a ${user.name}?\n\nEl usuario pasará a ser Usuario General.',
          style: const TextStyle(color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              setState(() => user.role = 'Usuario General');
              Navigator.pop(context);
              _showNotification('🗑️ Rol eliminado: ${user.name}');
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showNotification(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFF1E3A8A),
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Gestión de Roles',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // ── Header stats ──────────────────────────────────────────────
            Container(
              color: const Color(0xFF1E3A8A),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: kRoles.map((r) {
                  final count =
                      _users.where((u) => u.role == r).length;
                  final color = kRoleColors[r]!;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                          right: r != kRoles.last ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text('$count',
                              style: TextStyle(
                                  color: color == const Color(0xFF7C3AED)
                                      ? Colors.purple.shade200
                                      : color == const Color(0xFF2563EB)
                                          ? Colors.blue.shade200
                                          : Colors.cyan.shade200,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20)),
                          Text(
                            r.split(' ').first,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // ── Buscador ──────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o correo institucional...',
                  hintStyle:
                      const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: const Icon(Icons.search,
                      color: Color(0xFF2563EB), size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0), width: 1.5)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xFF2563EB), width: 2)),
                ),
              ),
            ),

            // ── Lista ─────────────────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text('Sin resultados',
                          style: TextStyle(color: Color(0xFF94A3B8))))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _UserTile(
                            user: filtered[i],
                            onEdit: () => _showRoleDialog(filtered[i]),
                            onDelete: () => _confirmDelete(filtered[i]),
                          ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tarjeta de usuario ────────────────────────────────────────────────────────
class _UserTile extends StatelessWidget {
  final AppUser user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _UserTile(
      {required this.user, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = kRoleColors[user.role] ?? const Color(0xFF2563EB);
    final icon = kRoleIcons[user.role] ?? Icons.person_outline;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(user.name,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1E293B))),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(user.role,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: Color(0xFF2563EB), size: 20),
              onPressed: onEdit,
              tooltip: 'Modificar rol',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Color(0xFFDC2626), size: 20),
              onPressed: onDelete,
              tooltip: 'Eliminar rol',
            ),
          ],
        ),
      ),
    );
  }
}