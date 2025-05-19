import 'package:flutter/material.dart';
import 'package:partice_project/screens/splash_screen.dart';
import 'package:partice_project/screens/started_screen.dart';
import 'package:partice_project/screens/login_screen.dart';
import 'package:partice_project/screens/signup_screen.dart';
import 'package:partice_project/screens/home_screen.dart';
import 'package:partice_project/screens/main_layout.dart';
import 'package:partice_project/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'services/favorites_service.dart';
import 'package:partice_project/utils/route_name.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => FavoritesService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rise Real Estate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: RoutesName.splashScreen,
      routes: {
        RoutesName.splashScreen: (context) => const SplashScreen(),
        RoutesName.startedScreen: (context) => const StartedScreen(),
        RoutesName.loginScreen: (context) => const LoginScreen(),
        RoutesName.signupScreen: (context) => const SignupScreen(),
        RoutesName.homeScreen: (context) => const MainLayout(),
      },
    );
  }
}

