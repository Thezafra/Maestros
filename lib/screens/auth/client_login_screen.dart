import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../widgets/responsive_layout.dart';
import '../legal/terms_and_conditions_screen.dart';

class ClientLoginScreen extends StatefulWidget {
  const ClientLoginScreen({super.key});

  @override
  State<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends State<ClientLoginScreen> {
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential.user != null) {
        await _saveUserToFirestore(credential.user!);
        await _saveRoleAndNavigate();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserToFirestore(User user) async {
    final userRef = FirebaseFirestore.instance.collection('clients').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      // Create new client document
      await userRef.set({
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName ?? 'Usuario',
        'photoUrl': user.photoURL,
        'role': 'client',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _saveRoleAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', 'client');

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final content =  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // On desktop, we don't need Spacer at top if centered
          const SizedBox(height: 40),
          // Logo or Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 60, color: Colors.deepPurple),
          ),
          const SizedBox(height: 24),
          const Text(
            'Bienvenido',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Inicia sesión para solicitar servicios y gestionar tus reservas fácilmente.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 40),
          
          if (_isLoading)
            const CircularProgressIndicator()
          else ...[
            // Google Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: _handleGoogleSignIn,
                icon: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                  height: 24,
                  errorBuilder: (c, e, s) => const Icon(Icons.login),
                ),
                label: const Text(
                  'Continuar con Google',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Guest Option
            TextButton(
              onPressed: _saveRoleAndNavigate,
              child: const Text('Continuar como Invitado', 
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen()),
                );
              },
              child: const Text('Términos y Condiciones', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ResponsiveLayout(
          mobileBody: Column(children: [const Spacer(), content, const Spacer()]),
          desktopBody: Center(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: SizedBox(
                width: 450,
                // height: 600, // Optional
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
