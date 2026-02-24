import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfessionalProfileScreen extends StatefulWidget {
  const EditProfessionalProfileScreen({super.key});

  @override
  State<EditProfessionalProfileScreen> createState() => _EditProfessionalProfileScreenState();
}

class _EditProfessionalProfileScreenState extends State<EditProfessionalProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _lastnameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  
  String? _selectedCategory;
  bool _isLoading = false;

  final List<String> _categories = [
    'Gasfitería',
    'Electricista',
    'Carpintería',
    'Pintura',
    'Limpieza',
    'Otros'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('professionals').doc(uid).get();
      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _nameCtrl.text = data['name'] ?? '';
          _lastnameCtrl.text = data['lastname'] ?? '';
          _phoneCtrl.text = data['phone'] ?? '';
          _aboutCtrl.text = data['about'] ?? '';
          _priceCtrl.text = (data['price']?.toString() ?? '');
          _selectedCategory = _categories.contains(data['job']) ? data['job'] : 'Otros';
        });
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastnameCtrl.dispose();
    _phoneCtrl.dispose();
    _aboutCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('professionals').doc(uid).update({
          'name': _nameCtrl.text.trim(),
          'lastname': _lastnameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'about': _aboutCtrl.text.trim(),
          'price': double.tryParse(_priceCtrl.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0,
          'job': _selectedCategory,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado correctamente')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Información Personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(child: _field(_nameCtrl, 'Nombre')),
                  const SizedBox(width: 12),
                  Expanded(child: _field(_lastnameCtrl, 'Apellido')),
                ],
              ),
              _field(_phoneCtrl, 'Teléfono', keyboard: TextInputType.phone),
              
              const SizedBox(height: 24),
              const Text('Información Profesional', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                decoration: InputDecoration(
                  labelText: 'Categoría / Oficio',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              _field(
                _priceCtrl, 
                'Precio referencial (Hora/Visita)', 
                keyboard: TextInputType.number,
                prefix: const Text('\$ '),
              ),

              _field(
                _aboutCtrl, 
                'Sobre mí (Descripción)', 
                maxLines: 4, 
                maxLength: 300,
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Guardar Cambios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    Widget? prefix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        maxLines: maxLines,
        maxLength: maxLength,
        validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefix != null ? Padding(padding: const EdgeInsets.only(left: 12, top: 12), child: prefix) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
          counterText: maxLength == null ? "" : null,
        ),
      ),
    );
  }
}
