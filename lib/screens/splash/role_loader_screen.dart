import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleLoaderScreen extends StatefulWidget {
  const RoleLoaderScreen({super.key});

  @override
  State<RoleLoaderScreen> createState() => _RoleLoaderScreenState();
}

class _RoleLoaderScreenState extends State<RoleLoaderScreen> {
  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role');

    await Future.delayed(const Duration(milliseconds: 600)); // suavidad visual

    if (!mounted) return;

    if (role == null) {
      Navigator.pushReplacementNamed(context, '/choose-role');
    } else if (role == 'client') {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/professional_login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF6F7FB),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
