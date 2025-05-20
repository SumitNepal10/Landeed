import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Landeed'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'About Landeed',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Landeed is a leading real estate platform dedicated to making property transactions easy, transparent, and secure. Our mission is to connect buyers, sellers, and renters with the best properties and services.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              'Contact Us',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Email: support@landeed.com'),
            Text('Phone: +1-234-567-8901'),
            SizedBox(height: 24),
            Text(
              'Our Vision',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('To be the most trusted and innovative real estate platform.'),
          ],
        ),
      ),
    );
  }
} 