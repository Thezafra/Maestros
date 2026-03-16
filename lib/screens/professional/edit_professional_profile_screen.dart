import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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

  // NUEVOS CAMPOS PARA FOTOS
  String? _photoUrl;
  List<String> _gallery = [];
  final ImagePicker _picker = ImagePicker();

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
          _photoUrl = data['photoUrl'];
          _gallery = List<String>.from(data['gallery'] ?? []);
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

  Future<String?> _uploadImage(XFile xFile, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      
      if (kIsWeb) {
        // En Web usamos bytes
        final bytes = await xFile.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        // En móvil usamos File
        await ref.putFile(File(xFile.path));
      }
      
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _pickProfilePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;

    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final url = await _uploadImage(image, 'professionals/$uid/profile.jpg');
      if (url != null) {
        setState(() => _photoUrl = url);
        await FirebaseFirestore.instance.collection('professionals').doc(uid).update({'photoUrl': url});
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addToGallery() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);
    if (images.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      List<String> newUrls = [];
      for (var image in images) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final url = await _uploadImage(image, 'professionals/$uid/gallery/$fileName');
        if (url != null) newUrls.add(url);
      }

      setState(() => _gallery.addAll(newUrls));
      await FirebaseFirestore.instance.collection('professionals').doc(uid).update({
        'gallery': FieldValue.arrayUnion(newUrls),
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFromGallery(String url) async {
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      setState(() => _gallery.remove(url));
      await FirebaseFirestore.instance.collection('professionals').doc(uid).update({
        'gallery': FieldValue.arrayRemove([url]),
      });
      
      // Opcional: Borrar de Storage si es necesario
      // FirebaseStorage.instance.refFromURL(url).delete();
    } finally {
      setState(() => _isLoading = false);
    }
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
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                      child: _photoUrl == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickProfilePhoto,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Galería de Trabajos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: _addToGallery,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Añadir'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (_gallery.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Center(child: Text('Aún no has subido fotos de tus trabajos', style: TextStyle(color: Colors.grey))),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _gallery.length,
                  itemBuilder: (context, index) {
                    final url = _gallery[index];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(url, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeFromGallery(url),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
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
