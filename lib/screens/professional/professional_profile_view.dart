import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfessionalProfileView extends StatelessWidget {
  const ProfessionalProfileView({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/choose-role', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('professionals')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final name = data?['name'] ?? 'Usuario';
          final job = data?['job'] ?? 'Profesional';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      job,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              _optionTile(Icons.person_outline, 'Editar Datos Personales', () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Próximamente: Editar Datos')));
              }),
              _optionTile(Icons.work_outline, 'Mis Servicios', () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Próximamente: Mis Servicios')));
              }),
              _optionTile(Icons.history, 'Historial de Trabajos', () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Próximamente: Historial')));
              }),
              _optionTile(Icons.settings_outlined, 'Configuración', () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Próximamente: Configuración')));
              }),
              
              const SizedBox(height: 20),
              _optionTile(Icons.logout, 'Cerrar Sesión', () => _logout(context), isDestructive: true),
            ],
          );
        },
      ),
    );
  }

  Widget _optionTile(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive ? Colors.red[50] : Colors.deepPurple[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: isDestructive ? Colors.red : Colors.deepPurple),
        ),
        title: Text(
          title, 
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}
