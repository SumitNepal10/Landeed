import 'screens/otp_verification_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';

// ... existing code ...

// Add these routes in your MaterialApp
routes: {
  // ... your existing routes ...
  '/verify-otp': (context) => OTPVerificationScreen(
        email: (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?)?['email'] ?? '',
        isPasswordReset: (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?)?['isPasswordReset'] ?? false,
        onVerificationSuccess: (data) {
          // Handle successful verification (e.g., store token, redirect to home)
          Navigator.pushReplacementNamed(context, '/home');
        },
      ),
  '/forgot-password': (context) => const ForgotPasswordScreen(),
  '/reset-password': (context) => const ResetPasswordScreen(),
},

// ... rest of your existing code ... 