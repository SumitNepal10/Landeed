import 'package:flutter/material.dart';
import 'package:partice_project/components/custom_bottom_nav.dart';
import 'package:partice_project/screens/home_screen.dart';
import 'package:partice_project/screens/menu_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text('News')),  // Placeholder
    const Center(child: Text('Add')),   // Placeholder
    const Center(child: Text('Favorites')), // Placeholder
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