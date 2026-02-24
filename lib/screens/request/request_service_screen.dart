import 'package:flutter/material.dart';
import '../../models/professional.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class RequestServiceScreen extends StatefulWidget {
  final Professional professional;

  const RequestServiceScreen({
    super.key,
    required this.professional,
  });

  @override
  State<RequestServiceScreen> createState() => _RequestServiceScreenState();
}

class _RequestServiceScreenState extends State<RequestServiceScreen> {
  final _detailsCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _isEmergency = false;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
  }
// ...
  Future<void> _loadUserAddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('clients').doc(uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _addressCtrl.text = doc.data()?['address'] ?? '';
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _loading = true);
    try {
      // 1. Check/Request Permissions
      var status = await Permission.location.request();
      if (status.isPermanentlyDenied) {
        throw 'Permiso de ubicación denegado permanentemente. Habilítalo en ajustes.';
      }
      if (!status.isGranted) {
        throw 'Necesitamos permiso de ubicación para esto.';
      }

      // 2. Get Position
      // Check if service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'El GPS está desactivado. Por favor actívalo.';
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Reverse Geocoding (Coords -> Address)
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Construct address string
        // e.g. "Av. Providencia 1234, Providencia"
        final street = place.street ?? '';
        final subLocality = place.subLocality ?? '';
        final locality = place.locality ?? '';
        
        String address = '$street, $subLocality';
        if (address.trim() == ',') address = locality; // Fallback
        
        setState(() {
          _addressCtrl.text = address;
        });
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('📍 Ubicación actualizada')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _detailsCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    final initial = _selectedDateTime ?? now.add(const Duration(days: 1));

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );

    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String _dateTimeLabel(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy • $hh:$min';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Solicitar servicio',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Estás solicitando a: ${widget.professional.name}',
              style: TextStyle(color: cs.onSurface.withOpacity(.7)),
            ),
            const SizedBox(height: 14),

            const Text('Describe el problema', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(
              'Cuéntanos los detalles para que el profesional pueda darte una cotización.',
              style: TextStyle(color: cs.onSurface.withOpacity(.7)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _detailsCtrl,
              minLines: 3,
              maxLines: 6,
              maxLength: 500, // Limit details
              decoration: InputDecoration(
                hintText: 'Ej: Mi lavaplatos gotea y está mojando todo…',
                filled: true,
                fillColor: cs.surfaceContainerHighest.withOpacity(.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 14),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Es una emergencia',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              subtitle: const Text('Necesito atención lo antes posible'),
              value: _isEmergency,
              onChanged: (val) => setState(() {
                _isEmergency = val ?? false;
                if (_isEmergency) _selectedDateTime = null;
              }),
            ),
            
            if (!_isEmergency) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickDateTime,
                  icon: const Icon(Icons.calendar_month, size: 28),
                  label: Text(
                    _selectedDateTime == null
                        ? 'Seleccionar fecha y hora'
                        : _dateTimeLabel(_selectedDateTime!),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    alignment: Alignment.centerLeft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
            const Text('Teléfono de contacto (WhatsApp)', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 20,
              decoration: InputDecoration(
                hintText: 'Ej: +569 1234 5678',
                counterText: "",
                filled: true,
                fillColor: cs.surfaceContainerHighest.withOpacity(.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Ubicación (Dirección)', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            TextField(
              controller: _addressCtrl,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'Ej: Av. Providencia 1234, Santiago',
                counterText: "", // Clean UI
                filled: true,
                fillColor: cs.surfaceContainerHighest.withOpacity(.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.place_outlined),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location, color: Colors.blue),
                  onPressed: _loading ? null : _getCurrentLocation,
                  tooltip: 'Usar mi ubicación actual',
                ),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _submitRequest,
                child: _loading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text('Solicitar cotización'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _loading = false;

  Future<void> _submitRequest() async {
    if (_detailsCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor describe el problema')),
      );
      return;
    }

    if (_phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un teléfono de contacto')),
      );
      return;
    }

    if (!_isEmergency && _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una fecha o marca Emergencia')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'No estás autenticado';

      // 1. Get Client Data
      final userDoc = await FirebaseFirestore.instance.collection('clients').doc(user.uid).get();
      // If not in 'clients', try 'users' or fallback
      String clientName = 'Cliente';
      if (userDoc.exists) {
        clientName = '${userDoc.data()?['name'] ?? ''} ${userDoc.data()?['lastname'] ?? ''}'.trim();
      } 
      if (clientName.isEmpty) clientName = user.email ?? 'Cliente';

      // 2. Create Reservation
      await FirebaseFirestore.instance.collection('reservations').add({
        'clientId': user.uid,
        'clientName': clientName,
        'clientPhone': _phoneCtrl.text.trim(), // Save the phone number
        'professionalId': widget.professional.id,
        'professionalName': widget.professional.name,
        'professionalJob': widget.professional.role,
        'professionalPhone': widget.professional.phone,
        'details': _detailsCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'isEmergency': _isEmergency,
        'scheduledDate': _isEmergency ? Timestamp.now() : Timestamp.fromDate(_selectedDateTime!),
        'status': 'Pendiente', 
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ ¡Solicitud enviada con éxito!')),
      );
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
