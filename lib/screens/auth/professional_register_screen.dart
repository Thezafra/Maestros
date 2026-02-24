import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/chile_data.dart';
import '../../utils/rut_validator.dart';
import '../../utils/categories_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../legal/terms_and_conditions_screen.dart';

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
  final _rutCtrl = TextEditingController(); // New
  final _certCtrl = TextEditingController(); // New
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

      // 2️⃣ Guardar perfil profesional en Firestore
      await FirebaseFirestore.instance
          .collection('professionals')
          .doc(uid)
          .set({
        'name': _nameCtrl.text.trim(),
        'lastname': _lastnameCtrl.text.trim(),
        'rut': _rutCtrl.text.trim(),
        'certificationNumber': _certCtrl.text.trim().isEmpty ? null : _certCtrl.text.trim(),
        'isVerified': false, // Starts unverified
        'job': _selectedJob,
        'yearsExperience': int.tryParse(_yearsExpCtrl.text) ?? 0,
        'region': _selectedRegion,
        'commune': _selectedCommune,
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'active': true,
      });

      // 3️⃣ Enviar correo de verificación
      await cred.user!.sendEmailVerification();

      if (!mounted) return;

      // 4️⃣ Mostrar diálogo de éxito y salir
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('¡Cuenta Creada!'),
          content: const Text(
            'Hemos enviado un correo de verificación.\n\n'
            'Por favor, revisa tu bandeja de entrada (y spam) y haz clic en el enlace para activar tu cuenta antes de iniciar sesión.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to Login
              },
              child: const Text('Entendido'),
            ),
          ],
        ),
      );

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
              _field(_nameCtrl, 'Nombre', maxLength: 50),
              _field(_lastnameCtrl, 'Apellido', maxLength: 50),
              
              // RUT Field
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'RUT (Ej: 12.345.678-9)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) {
                    final formatted = RutValidator.format(val);
                    if (_rutCtrl.text != formatted) {
                      _rutCtrl.value = _rutCtrl.value.copyWith(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  },
                  controller: _rutCtrl,
                  validator: (val) {
                     if (val == null || val.isEmpty) return 'Campo obligatorio';
                     if (!RutValidator.isValid(val)) return 'RUT inválido';
                     return null;
                  },
                ),
              ),
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
              // ... (Region/Commune omitted for brevity in replace, effectively unchanged if not targeted) ...
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
              
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: _yearsExpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Campo obligatorio';
                    final n = int.tryParse(v);
                    if (n == null) return 'Ingresa un número válido';
                    if (n < 0) return 'No puede ser negativo';
                    if (n > 70) return 'Máximo 70 años';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Años de Experiencia',
                    counterText: "",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              _field(_phoneCtrl, 'Teléfono', maxLength: 15, keyboard: TextInputType.phone),
              _field(_emailCtrl, 'Correo', keyboard: TextInputType.emailAddress),
              _field(_passwordCtrl, 'Contraseña', obscure: true),
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
              ),
               TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen()),
                  );
                },
                child: const Text('Al registrarte aceptas los Términos y Condiciones', 
                  style: TextStyle(color: Colors.grey, fontSize: 11)),
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
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboard,
        maxLength: maxLength,
        validator: validator ?? (v) =>
            v == null || v.isEmpty ? 'Campo obligatorio' : null,
        decoration: InputDecoration(
          labelText: label,
          counterText: maxLength == null ? null : "", // Hide counter if simple field, or keep default
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
