import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:landeed/services/auth_service.dart';
import 'package:landeed/screens/post_property_screen.dart';
import 'package:landeed/screens/main_layout.dart';
import 'package:landeed/utils/route_name.dart';
import 'package:landeed/screens/my_properties_screen.dart';
import 'package:landeed/screens/favorite_properties_screen.dart';
import 'package:landeed/screens/about_us_screen.dart';
import 'package:landeed/screens/terms_conditions_screen.dart';
import 'package:landeed/screens/user_profile_screen.dart';
import 'package:landeed/screens/chat_list_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  Widget _buildProfileImage(Map<String, dynamic>? userData) {
    if (userData != null && userData['profileImage'] != null && userData['profileImage'].isNotEmpty) {
      try {
        final imageBytes = base64Decode(userData['profileImage']);
        return CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[200],
          backgroundImage: MemoryImage(imageBytes),
        );
      } catch (e) {
        return const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, size: 50, color: Colors.white),
        );
      }
    }
    return const CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey,
      child: Icon(Icons.person, size: 50, color: Colors.white),
    );
  }

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
                  _buildProfileImage(userData),
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
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserProfileScreen(startInEditMode: true),
                        ),
                      );
                    },
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
              icon: Icons.chat,
              title: 'Chat History',
              onTap: () {
                final userId = authService.userData?['id'] ?? '';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatListScreen(
                      userId: userId,
                      baseUrl: 'http://192.168.1.2:3000',
                    ),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.home_work_outlined,
              title: 'My Properties',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyPropertiesScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.favorite,
              title: 'Favorite Properties',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritePropertiesScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.logout,
              title: 'Logout',
              onTap: () async {
                await authService.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, RoutesName.loginScreen);
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutUsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.contact_mail,
              title: 'Contact Us',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Contact Us'),
                    content: const Text('Email: support@landeed.com\nPhone: +1-234-567-8901'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Privacy Policy'),
                    content: const Text('Read our privacy policy at https://landeed.com/privacy'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.article,
              title: 'Terms & Conditions',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsConditionsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserProfileScreen(startInEditMode: true),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.lock_reset,
              title: 'Change Password',
              onTap: () {
                Navigator.pushNamed(context, RoutesName.forgotPasswordScreen);
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