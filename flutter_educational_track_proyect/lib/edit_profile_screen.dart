import 'package:flutter/material.dart';
import 'api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ApiService _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = _api.currentUser;
    if (user != null) {
      _nombreController.text = user.nombreCompleto ?? '';
      _telefonoController.text = user.telefono ?? '';
      _emailController.text = user.email;
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_newPasswordController.text.isNotEmpty &&
        _newPasswordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final success = await _api.editarPerfil(
      nombreCompleto: _nombreController.text.trim(),
      telefono: _telefonoController.text.trim(),
      email: _emailController.text.trim(),
      nuevaPassword: _newPasswordController.text.isEmpty ? null : _newPasswordController.text,
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar'), backgroundColor: Colors.red),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil'), backgroundColor: const Color(0xFF1E3A8A)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre completo')),
              TextFormField(controller: _telefonoController, decoration: const InputDecoration(labelText: 'Teléfono')),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Correo electrónico'), keyboardType: TextInputType.emailAddress),
              const Divider(height: 40),
              const Text('Cambiar contraseña (opcional)', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(controller: _newPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'Nueva contraseña')),
              TextFormField(controller: _confirmController, obscureText: true, decoration: const InputDecoration(labelText: 'Confirmar contraseña')),
              const SizedBox(height: 30),
              ElevatedButton(onPressed: _isLoading ? null : _guardar, child: const Text('Guardar cambios')),
            ],
          ),
        ),
      ),
    );
  }
}