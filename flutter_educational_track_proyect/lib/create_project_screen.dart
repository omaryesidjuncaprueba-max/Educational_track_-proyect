import 'package:flutter/material.dart';
import 'api_service.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final ApiService _api = ApiService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tituloCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  List<TextEditingController> _autorCtrls = [TextEditingController(), TextEditingController()];

  // Listas según lo solicitado
  final List<String> _tipos = [
    'Aprendizaje, conocimiento, tecnologías, comunicación y digitalización',
    'Gestión, emprendimiento, organizaciones sociales del conocimiento y aprendizaje',
    'Transmodernidad, naturaleza, ambiente, biodiversidad, ancestralidad y familia',
  ];

  final List<String> _categorias = [
    'Proyecto Tecnológico',
    'Proyecto de investigación',
    'Proyecto comunitario',
    'Proyecto de emprendimiento e innovación',
  ];

  String _tipoSeleccionado = '';
  String _categoriaSeleccionada = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (_tipos.isNotEmpty) _tipoSeleccionado = _tipos[0];
    if (_categorias.isNotEmpty) _categoriaSeleccionada = _categorias[0];
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    for (var c in _autorCtrls) c.dispose();
    super.dispose();
  }

  void _agregarAutor() {
    setState(() {
      _autorCtrls.add(TextEditingController());
    });
  }

  void _eliminarAutor(int index) {
    if (_autorCtrls.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe haber al menos 2 autores'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() {
      _autorCtrls[index].dispose();
      _autorCtrls.removeAt(index);
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    List<String> autores = _autorCtrls.map((c) => c.text.trim()).where((e) => e.isNotEmpty).toList();
    if (autores.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete al menos 2 autores'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await _api.createProject(
      titulo: _tituloCtrl.text.trim(),
      descripcion: _descCtrl.text.trim(),
      autores: autores,
      tipo: _tipoSeleccionado,
      categoria: _categoriaSeleccionada,
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proyecto enviado a revisión'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al publicar proyecto'), backgroundColor: Colors.red),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postular Proyecto'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextFormField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _tipoSeleccionado,
                decoration: const InputDecoration(labelText: 'Tipo de proyecto', border: OutlineInputBorder()),
                items: _tipos.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _tipoSeleccionado = v!),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                items: _categorias.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _categoriaSeleccionada = v!),
              ),
              const SizedBox(height: 15),
              const Text('Autores (mínimo 2):', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._autorCtrls.asMap().entries.map((entry) {
                int idx = entry.key;
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: entry.value,
                        decoration: InputDecoration(hintText: 'Correo del autor ${idx + 1}'),
                        validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _eliminarAutor(idx),
                    ),
                  ],
                );
              }),
              TextButton.icon(
                onPressed: _agregarAutor,
                icon: const Icon(Icons.add),
                label: const Text('Agregar autor'),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardar,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Enviar a revisión'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}