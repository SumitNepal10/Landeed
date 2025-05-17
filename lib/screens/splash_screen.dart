import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:partice_project/services/auth_service.dart';
import 'package:partice_project/utils/route_name.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.checkAuthStatus();
    
    if (mounted) {
      if (authService.isAuthenticated) {
        Navigator.pushReplacementNamed(context, RoutesName.homeScreen);
      } else {
        Navigator.pushReplacementNamed(context, RoutesName.startedScreen);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
