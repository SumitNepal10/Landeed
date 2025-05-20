import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Terms & Conditions',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'By using Landeed, you agree to the following terms and conditions. Please read them carefully.\n\n'
                '1. Use of Service: Landeed provides a platform for property listings and related services.\n'
                '2. User Responsibilities: Users are responsible for the accuracy of their listings and for complying with all applicable laws.\n'
                '3. Privacy: We respect your privacy. Please review our privacy policy for more information.\n'
                '4. Limitation of Liability: Landeed is not liable for any damages arising from the use of our platform.\n'
                '5. Changes: We may update these terms at any time. Continued use of the service constitutes acceptance of the new terms.\n\n'
                'For the full terms and conditions, visit our website.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 