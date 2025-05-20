import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:landeed/screens/login_screen.dart';
import 'package:landeed/screens/signup_screen.dart';
import 'package:landeed/screens/main_layout.dart';
import 'package:landeed/screens/onboarding_screen.dart';
import 'package:landeed/screens/otp_screen.dart';
import 'package:landeed/screens/dashboard_screen.dart';
import 'package:landeed/screens/admin/admin_dashboard_screen.dart';
import 'package:landeed/screens/notifications_screen.dart';
import 'package:landeed/services/auth_service.dart';
import 'package:landeed/services/property_service.dart';
import 'services/favorites_service.dart';
import 'package:landeed/utils/route_name.dart';
import 'providers/property_provider.dart';
import 'providers/notification_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => FavoritesService()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ProxyProvider<AuthService, PropertyService>(
          update: (context, authService, previous) => PropertyService(authService),
        ),
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
      initialRoute: RoutesName.onboardingScreen,
      routes: {
        RoutesName.onboardingScreen: (context) => const OnboardingScreen(),
        RoutesName.loginScreen: (context) => const LoginScreen(),
        RoutesName.signupScreen: (context) => const SignupScreen(),
        RoutesName.homeScreen: (context) => const MainLayout(),
        RoutesName.otpScreen: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return OtpScreen(
            phoneNumber: args['phoneNumber'],
            verificationId: args['verificationId'],
          );
        },
        RoutesName.authScreen: (context) => const DashboardScreen(),
        RoutesName.adminDashboard: (context) => const AdminDashboardScreen(),
        RoutesName.notificationsScreen: (context) => const NotificationsScreen(),
      },
    );
  }
}