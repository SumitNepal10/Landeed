import 'package:flutter/material.dart';
import 'package:partice_project/components/app_button.dart';
import 'package:partice_project/components/gap.dart';
import 'package:partice_project/components/login_footer.dart';
import 'package:partice_project/constant/colors.dart';
import 'package:partice_project/services/api_service.dart';
import 'package:partice_project/utils/route_name.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _fullNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.signup(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim(),
        fullName: _fullNameController.text.trim(),
      );

      // Store token and user data
      // TODO: Implement secure storage for token and user data

      if (mounted) {
        Navigator.pushReplacementNamed(context, RoutesName.homeScreen);
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
                    children: [
                      Text(
                        "Create ",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      Text(
                        "Account",
                        style: Theme.of(context).textTheme.displayMedium!.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  Gap(isWidth: false, isHeight: true, height: height * 0.035),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      hintText: "Full Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  Gap(isWidth: false, isHeight: true, height: height * 0.02),
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
                      return null;
                    },
                  ),
                  Gap(isWidth: false, isHeight: true, height: height * 0.02),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: "Phone Number",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  Gap(isWidth: false, isHeight: true, height: height * 0.02),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
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
                  Gap(isWidth: false, isHeight: true, height: height * 0.035),
                  AppButton(
                    onPress: _isLoading ? () {} : () => _signup(),
                    title: _isLoading ? "Creating Account..." : "Sign Up",
                    textColor: AppColors.whiteColor,
                    isButtonIcon: true,
                    height: height * 0.08,
                    radius: 15,
                  ),
                  Gap(isWidth: false, isHeight: true, height: height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                              context, RoutesName.loginScreen);
                        },
                        child: Text(
                          "Sign In",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
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
