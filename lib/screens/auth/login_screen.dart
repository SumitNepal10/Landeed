import 'package:flutter/material.dart';
import 'package:partice_project/components/app_button.dart';
import 'package:partice_project/components/gap.dart';
import 'package:partice_project/constant/colors.dart';
import 'package:partice_project/services/auth_service.dart';
import 'package:partice_project/utils/route_name.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final email = _emailController.text.trim();
      
      final result = await authService.login(email, _passwordController.text);
      
      if (!mounted) return;

      if (result['success'] == true) {
        if (result['isAdmin'] == true) {
          // Admin login successful
          Navigator.of(context).pushNamedAndRemoveUntil(
            RoutesName.adminDashboard,
            (route) => false,
          );
        } else {
          // User login successful
          Navigator.pushReplacementNamed(context, RoutesName.homeScreen);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const Gap(isWidth: false, isHeight: true, height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    hintText: 'Use @gmail.com for users or @landeed.com for admins',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    if (!value.endsWith('@gmail.com') && !value.endsWith('@landeed.com')) {
                      return 'Please use @gmail.com for users or @landeed.com for admins';
                    }
                    return null;
                  },
                ),
                const Gap(isWidth: false, isHeight: true, height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const Gap(isWidth: false, isHeight: true, height: 24),
                AppButton(
                  title: _isLoading ? 'Logging in...' : 'Login',
                  onPress: _isLoading ? null : _login,
                ),
                const Gap(isWidth: false, isHeight: true, height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RoutesName.signupScreen);
                  },
                  child: const Text('Don\'t have an account? Sign up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 