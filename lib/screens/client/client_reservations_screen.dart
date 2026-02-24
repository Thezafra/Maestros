import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientReservationsScreen extends StatelessWidget {
  const ClientReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('es_CL', null);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reservations')
            .where('clientId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No tienes reservas activas', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final dateTs = data['scheduledDate'] as Timestamp?;
              final dateStr = dateTs != null 
                  ? DateFormat('EEE d MMM - HH:mm', 'es_CL').format(dateTs.toDate())
                  : 'Fecha pendiente';
              final status = data['status'] ?? 'Pendiente';

              Color statusColor = Colors.orange;
              if (status == 'Confirmado') statusColor = Colors.green;
              if (status == 'Rechazado') statusColor = Colors.red;
              if (status == 'Completado') statusColor = Colors.blueGrey;

              final hasRated = data['rating'] != null;

              return _ReservationCard(
                reservationId: docs[index].id,
                professionalId: data['professionalId'],
                proName: data['professionalName'] ?? 'Profesional',
                service: data['professionalJob'] ?? 'Servicio',
                date: dateStr,
                status: status,
                statusColor: statusColor,
                isPast: status == 'Completado' || status == 'Rechazado',
                hasRated: hasRated,
                phone: data['professionalPhone'],
                details: data['details'] ?? 'Sin descripción',
                address: data['address'] ?? 'Sin dirección',
              );
            },
          );
        },
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final String reservationId;
  final String professionalId;
  final String proName;
  final String service;
  final String date;
  final String status;
  final Color statusColor;
  final bool isPast;
  final bool hasRated;
  final String? phone;
  final String details; // New field
  final String address; // New field

  const _ReservationCard({
    required this.reservationId,
    required this.professionalId,
    required this.proName,
    required this.service,
    required this.date,
    required this.status,
    required this.statusColor,
    this.isPast = false,
    this.hasRated = false,
    this.phone,
    required this.details,
    required this.address,
  });

  // ... (keep _launchWhatsApp and _showRatingDialog as is or assume they are there)

  // New Method for Details Dialog
  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Detalles de la Reserva'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow(Icons.description, 'Problema', details),
                const SizedBox(height: 16),
                _detailRow(Icons.place, 'Dirección', address),
                const SizedBox(height: 16),
                _detailRow(Icons.calendar_today, 'Fecha', date),
                const SizedBox(height: 16),
                _detailRow(Icons.info_outline, 'Estado', status, color: statusColor),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value, 
                style: TextStyle(fontSize: 15, color: color ?? Colors.black87, fontWeight: color != null ? FontWeight.bold : FontWeight.normal),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ... (keep _launchWhatsApp and _showRatingDialog) 
  // IMPORTANT: Since replace_file_content replaces a block, I need to be careful not to delete existing methods if I target the whole class.
  // Strategy: I will replace the Constructor and Build method segments, or just the whole class if easier but that's risky with hidden code.
  // Actually, I can add the new fields and methods, and update the build method.
  
  // Let's replace the whole class content shown in the context to be safe, reusing existing methods logic.
  // Wait, I don't want to rewrite _showRatingDialog and _submitRating if I can avoid it.
  // I'll target specific parts.

  // 1. Update Constructor and Fields
  // 2. Update Build method to call _showDetailsDialog
  
  // But I need to add _showDetailsDialog and _detailRow methods too. 
  // I will just append them before the build method and update the build method to use it.

  Future<void> _launchWhatsApp(BuildContext context) async {
    if (phone == null || phone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este profesional no tiene teléfono registrado')),
      );
      return;
    }

    final cleanPhone = phone!.replaceAll(RegExp(r'\D'), '');
    final url = Uri.parse('https://wa.me/$cleanPhone');

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'No se pudo abrir WhatsApp';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    }
  }

  void _showRatingDialog(BuildContext context) {
    int selectedStars = 5;
    final commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Calificar Servicio'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('¿Qué tal estuvo el servicio?'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () => setDialogState(() => selectedStars = index + 1),
                        icon: Icon(
                          index < selectedStars ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Comentario (Opcional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _submitRating(context, selectedStars, commentCtrl.text);
                  },
                  child: const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitRating(BuildContext context, int stars, String comment) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final proRef = FirebaseFirestore.instance.collection('professionals').doc(professionalId);
        final resRef = FirebaseFirestore.instance.collection('reservations').doc(reservationId);

        final proDoc = await transaction.get(proRef);
        if (!proDoc.exists) throw 'Profesional no encontrado';

        final currentRating = (proDoc.data()?['rating'] as num?)?.toDouble() ?? 5.0;
        final currentJobs = (proDoc.data()?['jobsDone'] as num?)?.toInt() ?? 0;

        // Calculate new average
        // (OldAvg * OldCount + NewRating) / (OldCount + 1)
        double newRating = ((currentRating * currentJobs) + stars) / (currentJobs + 1);
        
        // Update Professional
        transaction.update(proRef, {
          'rating': newRating,
          'jobsDone': currentJobs + 1,
        });

        // Update Reservation
        transaction.update(resRef, {
          'rating': stars,
          'review': comment,
        });
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Gracias por tu calificación! ⭐')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al calificar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                service,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                proName,
                style: const TextStyle(color: Colors.black54),
              ),
              const Spacer(),
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                date,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              // Contact Button (Always visible if phone exists and not rejected?)
              // Generally logical to allow contact even if completed for warranty etc.
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _launchWhatsApp(context),
                  child: const Text('Contactar'),
                ),
              ),
              const SizedBox(width: 12),
              
              // Action Button (Rate or View)
              Expanded(
                child: (status == 'Completado' && !hasRated)
                    ? FilledButton.icon(
                        onPressed: () => _showRatingDialog(context),
                        icon: const Icon(Icons.star, size: 16),
                        label: const Text('Calificar'),
                        style: FilledButton.styleFrom(backgroundColor: Colors.amber[700]),
                      )
                    : FilledButton(
                        onPressed: () => _showDetailsDialog(context),
                        style: FilledButton.styleFrom(
                           backgroundColor: Colors.grey[100], 
                           foregroundColor: Colors.black
                        ),
                        child: const Text('Ver Detalle'),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
