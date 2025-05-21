import 'package:flutter/material.dart';
import 'package:landeed/components/app_button.dart';
import 'package:landeed/components/gap.dart';
import 'package:landeed/components/login_footer.dart';
import 'package:landeed/components/login_option.dart';
import 'package:landeed/constant/colors.dart';
import 'package:provider/provider.dart';
import 'package:landeed/services/auth_service.dart';
import 'package:landeed/utils/route_name.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

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
      final isAdmin = _emailController.text.trim().endsWith('@landeed.com');
      final result = await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        isAdmin: isAdmin,
      );

      if (result['success']) {
        if (isAdmin) {
          Navigator.pushReplacementNamed(context, RoutesName.adminDashboard);
        } else {
          Navigator.pushReplacementNamed(context, RoutesName.homeScreen);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: const [
                      LoginOption(path: "lib/assets/images/login1.png"),
                      Gap(isWidth: true, isHeight: false, width: 10),
                      LoginOption(path: "lib/assets/images/login2.png"),
                    ],
                  ),
                  Gap(isWidth: false, isHeight: true, height: height * 0.01),
                  Row(
                    children: const [
                      LoginOption(path: "lib/assets/images/login3.png"),
                      Gap(isWidth: true, isHeight: false, width: 10),
                      LoginOption(path: "lib/assets/images/login4.png"),
                    ],
                  ),
                  Gap(isWidth: false, isHeight: true, height: height * 0.035),
                  Row(
                    children: [
                      Text(
                        "Let's ",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      Text(
                        "Sign In",
                        style: Theme.of(context).textTheme.displayMedium!.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  Gap(isWidth: false, isHeight: true, height: height * 0.035),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      // Allow both regular user and admin email domains
                      if (!value.endsWith('@gmail.com') && !value.endsWith('@landeed.com')) {
                        return 'Please use valid email';
                      }
                      return null;
                    },
                  ),
                  Gap(isWidth: false, isHeight: true, height: height * 0.02),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      hintText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                    ),
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
                  Gap(isWidth: false, isHeight: true, height: height * 0.02),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, RoutesName.forgotPasswordScreen);
                      },
                      child: Text(
                        "Forgot Password?",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Gap(isWidth: false, isHeight: true, height: height * 0.035),
                  AppButton(
                    onPress: _isLoading ? () {} : () => _login(),
                    title: _isLoading ? "Signing in..." : "Sign In",
                    textColor: AppColors.whiteColor,
                    isButtonIcon: true,
                    height: height * 0.08,
                    radius: 15,
                  ),
                  Gap(isWidth: false, isHeight: true, height: height * 0.02),
                  
                  const LoginFooter()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
