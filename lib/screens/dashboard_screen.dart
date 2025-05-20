import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:landeed/constant/colors.dart';
import 'package:landeed/components/custom_bottom_nav.dart';
import 'package:landeed/screens/account_profile_screen.dart';
import 'package:landeed/screens/favourite_screen.dart';
import 'package:landeed/screens/home_screen.dart';
import 'package:landeed/screens/post_property_screen.dart';
import 'package:landeed/screens/login_screen.dart';
import 'package:landeed/screens/properties_screen.dart';
import 'package:landeed/services/auth_service.dart';
import 'package:landeed/utils/route_name.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  bool _isLoggingOut = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PropertiesScreen(),
    const PostPropertyScreen(),
    const FavouriteScreen(),
    const AccountProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoggingOut = true;
      });

      try {
        await _authService.logout();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RoutesName.loginScreen,
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to logout. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoggingOut = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rise Real Estate'),
        actions: [
          if (_isLoggingOut)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleLogout,
            ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
