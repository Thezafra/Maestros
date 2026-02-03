import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/chile_data.dart';
import '../../utils/categories_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfessionalRegisterScreen extends StatefulWidget {
  const ProfessionalRegisterScreen({super.key});

  @override
  State<ProfessionalRegisterScreen> createState() =>
      _ProfessionalRegisterScreenState();
}

class _ProfessionalRegisterScreenState
    extends State<ProfessionalRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _lastnameCtrl = TextEditingController();
  // New field
  final _yearsExpCtrl = TextEditingController();
  // _jobCtrl removed
  String? _selectedJob;
  // _cityCtrl removed
  String? _selectedRegion;
  String? _selectedCommune;

  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // 1️⃣ Crear usuario en Firebase Auth (Time out 30s)
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        throw 'Tiempo de espera agotado al crear usuario. Verifica tu internet.';
      });

      final uid = cred.user!.uid;

      // 2️⃣ Guardar perfil profesional en Firestore (Time out 30s)
      await FirebaseFirestore.instance
          .collection('professionals')
          .doc(uid)
          .set({
        'name': _nameCtrl.text.trim(),
        'lastname': _lastnameCtrl.text.trim(),
        'job': _selectedJob,
        'yearsExperience': int.tryParse(_yearsExpCtrl.text) ?? 0,
        'region': _selectedRegion,
        'commune': _selectedCommune,
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'active': true,
      }).timeout(const Duration(seconds: 30), onTimeout: () {
        throw 'Tiempo de espera agotado al guardar datos.';
      });

      // 2.5️⃣ Guardar rol en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', 'professional');

      if (!mounted) return;

      // 3️⃣ Ir al dashboard profesional
      Navigator.pushReplacementNamed(context, '/professional_dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastnameCtrl.dispose();
    _yearsExpCtrl.dispose();
    // _jobCtrl.dispose() removed
    // _cityCtrl.dispose() removed
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro Profesional')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(_nameCtrl, 'Nombre'),
              _field(_lastnameCtrl, 'Apellido'),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<String>(
                  value: _selectedJob,
                  decoration: InputDecoration(
                    labelText: 'Oficio',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: CategoryData.names.map((job) {
                    return DropdownMenuItem(
                      value: job,
                      child: Text(job),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedJob = val),
                  validator: (val) =>
                      val == null ? 'Selecciona un oficio' : null,
                ),
              ),
              // Region Dropdown
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<String>(
                  value: _selectedRegion,
                  decoration: InputDecoration(
                    labelText: 'Región',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: ChileData.regiones.keys.map((region) {
                    return DropdownMenuItem(
                      value: region,
                      child: Text(region, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val == _selectedRegion) return;
                    setState(() {
                      _selectedRegion = val;
                      _selectedCommune = null;
                    });
                  },
                  validator: (val) => val == null ? 'Selecciona una región' : null,
                ),
              ),
              // Commune Dropdown
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<String>(
                  value: _selectedCommune,
                  decoration: InputDecoration(
                    labelText: 'Comuna',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _selectedRegion == null
                      ? []
                      : ChileData.regiones[_selectedRegion]!.map((commune) {
                          return DropdownMenuItem(
                            value: commune,
                            child:
                                Text(commune, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                  onChanged: _selectedRegion == null
                      ? null
                      : (val) => setState(() => _selectedCommune = val),
                  validator: (val) =>
                      val == null ? 'Selecciona una comuna' : null,
                ),
              ),
              _field(_yearsExpCtrl, 'Años de Experiencia',
                  keyboard: TextInputType.number),
              _field(_phoneCtrl, 'Teléfono',
                  keyboard: TextInputType.phone),
              _field(_emailCtrl, 'Correo',
                  keyboard: TextInputType.emailAddress),
              _field(_passwordCtrl, 'Contraseña',
                  obscure: true),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Registrarme'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboard,
        validator: (v) =>
            v == null || v.isEmpty ? 'Campo obligatorio' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
