import 'package:flutter/material.dart';
import 'package:landeed/components/custom_bottom_nav.dart';
import 'package:landeed/screens/home_screen.dart';
import 'package:landeed/screens/menu_screen.dart';
import 'package:landeed/screens/post_property_screen.dart';
import 'package:landeed/screens/favorite_properties_screen.dart';
import 'package:provider/provider.dart';
import 'package:landeed/providers/notification_provider.dart';
import 'package:landeed/utils/route_name.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 0});

  static void navigateToTab(BuildContext context, int tabIndex) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainLayout(initialIndex: tabIndex),
      ),
    );
  }

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text('News')),  // Placeholder
    const PostPropertyScreen(),
    const FavoritePropertiesScreen(),
    const MenuScreen(),
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
} 