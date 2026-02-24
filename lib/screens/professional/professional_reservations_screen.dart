import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfessionalReservationsScreen extends StatelessWidget {
  const ProfessionalReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Mi Agenda'),
        backgroundColor: Colors.white,
        elevation: 0,
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
            .where('professionalId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
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
                  Text('No tienes trabajos agendados', style: TextStyle(color: Colors.grey)),
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
              final timeStr = dateTs != null 
                  ? DateFormat('HH:mm').format(dateTs.toDate())
                  : '--:--';
              
              final status = data['status'] ?? 'Pendiente';
              Color statusColor = Colors.orange;
              if (status == 'Confirmado') statusColor = Colors.blue;
              if (status == 'En camino') statusColor = Colors.purple;
              if (status == 'Completado') statusColor = Colors.green;
              if (status == 'Rechazado') statusColor = Colors.red;

              return _AgendaItem(
                docId: docs[index].id,
                time: timeStr,
                client: data['clientName'] ?? 'Cliente sin nombre',
                clientPhone: data['clientPhone'], // Pass phone
                address: data['address'] ?? 'Dirección por confirmar',
                task: data['details'] ?? 'Sin detalles',
                status: status,
                color: statusColor,
              );
            },
          );
        },
      ),
    );
  }
}

class _AgendaItem extends StatelessWidget {
  final String docId;
  final String time;
  final String client;
  final String? clientPhone;
  final String address;
  final String task;
  final String status;
  final Color color;

  const _AgendaItem({
    required this.docId,
    required this.time,
    required this.client,
    this.clientPhone,
    required this.address,
    required this.task,
    required this.status,
    required this.color,
  });

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(docId)
          .update({'status': newStatus});
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reserva actualizada a: $newStatus')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _contactClient(BuildContext context) async {
    if (clientPhone == null || clientPhone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El cliente no dejó teléfono de contacto')),
      );
      return;
    }

    final cleanPhone = clientPhone!.replaceAll(RegExp(r'\D'), '');
    // Ensure it has country code if possible, or assume Chile (+56) if missing
    // For simplicity, just use what is provided, assuming user enters it or we cleaned it enough.
    // If it starts with 9 (common in Chile without +56), prepend +56.
    String finalPhone = cleanPhone;
    if (finalPhone.length == 9 && finalPhone.startsWith('9')) {
        finalPhone = '56$finalPhone';
    }
    
    final url = Uri.parse('https://wa.me/$finalPhone');
    
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

  @override
  Widget build(BuildContext context) {
    bool isPending = (status == 'Pendiente');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border(left: BorderSide(color: color, width: 4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                      Text(
                        client,
                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                      ),
                  if (clientPhone != null && clientPhone!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: () => _contactClient(context),
                          icon: const Icon(Icons.chat, size: 18, color: Colors.white),
                          label: const Text('Contactar por WhatsApp', style: TextStyle(color: Colors.white, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isPending)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () => _updateStatus(context, 'Confirmado'),
                              tooltip: 'Aceptar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () => _updateStatus(context, 'Rechazado'),
                              tooltip: 'Rechazar',
                            ),
                          ],
                        ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
