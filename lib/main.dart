import 'package:flutter/material.dart';
import 'package:partice_project/screens/splash_screen.dart';
import 'package:partice_project/screens/started_screen.dart';
import 'package:partice_project/screens/login_screen.dart';
import 'package:partice_project/screens/signup_screen.dart';
import 'package:partice_project/screens/home_screen.dart';
import 'package:partice_project/services/auth_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'Rise Real Estate',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/started': (context) => const StartedScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
