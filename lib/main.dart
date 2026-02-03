import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// SCREENS
import 'screens/home_screen.dart';
import 'screens/splash/role_loader_screen.dart';
import 'screens/role/choose_role_screen.dart';
import 'screens/auth/professional_login_screen.dart';
import 'screens/auth/client_login_screen.dart';
import 'screens/professional/professional_dashboard_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maestros',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const RoleLoaderScreen(),
        '/choose-role': (_) => const ChooseRoleScreen(),
        '/home': (_) => const HomeScreen(),
        '/client_login': (_) => const ClientLoginScreen(),
        '/professional_login': (_) => const ProfessionalLoginScreen(),
        '/professional_dashboard': (_) => const ProfessionalDashboardScreen(),
      },
    );
  }
}
