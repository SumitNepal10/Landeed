import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:partice_project/services/auth_service.dart';
import 'package:partice_project/constant/colors.dart';
import 'package:partice_project/screens/post_property_screen.dart';
import 'package:partice_project/screens/main_layout.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userData = authService.userData;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userData?['fullName'] ?? 'User Name',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userData?['email'] ?? 'email@example.com',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildMenuItem(
              context,
              icon: Icons.post_add,
              title: 'Post Property',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PostPropertyScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.favorite_border,
              title: 'Favorites',
              onTap: () {
                MainLayout.navigateToTab(context, 3);
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.remove_red_eye_outlined,
              title: 'Recently Viewed',
              onTap: () {
                // TODO: Navigate to recently viewed screen
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.home_work_outlined,
              title: 'My Properties',
              onTap: () {
                // TODO: Navigate to my properties screen
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.logout,
              title: 'Logout',
              onTap: () async {
                await authService.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'About US',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildMenuItem(
              context,
              icon: Icons.info_outline,
              title: 'About Landeed',
              onTap: () {
                // TODO: Navigate to about screen
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
} 