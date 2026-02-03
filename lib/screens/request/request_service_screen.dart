import 'package:flutter/material.dart';
import '../../models/professional.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  bool _isEmergency = false;
  DateTime? _selectedDateTime;

  @override
  void dispose() {
    _detailsCtrl.dispose();
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

            const Text('Horario', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),

            // Emergencia (toggle)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(.4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_fire_department_outlined, color: cs.onSurface.withOpacity(.85)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Emergencia', style: TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 2),
                        Text(
                          'El profesional llegará ASAP',
                          style: TextStyle(color: cs.onSurface.withOpacity(.65), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isEmergency,
                    onChanged: (v) => setState(() => _isEmergency = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Fecha + Hora (un solo bloque)
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _isEmergency ? null : _pickDateTime,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(.4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Seleccionar fecha y hora', style: TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 2),
                          Text(
                            _isEmergency
                                ? 'Lo antes posible'
                                : (_selectedDateTime == null
                                    ? 'Toca para elegir'
                                    : _dateTimeLabel(_selectedDateTime!)),
                            style: TextStyle(color: cs.onSurface.withOpacity(.7), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit, color: cs.onSurface.withOpacity(.6)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text('Ubicación', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(.4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.place_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Agregar dirección (más adelante)',
                      style: TextStyle(color: cs.onSurface.withOpacity(.7)),
                    ),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Cambiar')),
                ],
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
        'professionalId': widget.professional.id,
        'professionalName': widget.professional.name,
        'professionalJob': widget.professional.role,
        'details': _detailsCtrl.text.trim(),
        'isEmergency': _isEmergency,
        'scheduledDate': _isEmergency ? Timestamp.now() : Timestamp.fromDate(_selectedDateTime!),
        'status': 'Pendiente', // Pendiente, Confirmado, Completado, Rechazado
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
