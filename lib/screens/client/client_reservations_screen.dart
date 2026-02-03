import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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

              return _ReservationCard(
                proName: data['professionalName'] ?? 'Profesional',
                service: data['professionalJob'] ?? 'Servicio',
                date: dateStr,
                status: status,
                statusColor: statusColor,
                isPast: status == 'Completado' || status == 'Rechazado',
              );
            },
          );
        },
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final String proName;
  final String service;
  final String date;
  final String status;
  final Color statusColor;
  final bool isPast;

  const _ReservationCard({
    required this.proName,
    required this.service,
    required this.date,
    required this.status,
    required this.statusColor,
    this.isPast = false,
  });

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
          if (!isPast) ...[
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Contactar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {},
                    child: const Text('Ver Detalle'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
