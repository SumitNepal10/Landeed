import 'package:flutter/material.dart';
import 'package:partice_project/components/app_button.dart';
import 'package:partice_project/components/gap.dart';
import 'package:partice_project/constant/colors.dart';
import 'package:partice_project/constant/api_constants.dart';
import 'package:partice_project/screens/admin/property_verification_screen.dart';
import 'package:partice_project/services/auth_service.dart';
import 'package:partice_project/utils/route_name.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  List<dynamic> _properties = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final adminToken = await authService.getAdminToken();

      if (adminToken == null) {
        throw Exception('Admin token not found');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/properties/pending'),
        headers: {
          'Authorization': 'Bearer $adminToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _properties = data;
          _isLoading = false;
        });
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to load properties');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProperties,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.logout();
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed(RoutesName.loginScreen);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProperties,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _properties.isEmpty
                  ? const Center(child: Text('No properties found'))
                  : ListView.builder(
                      itemCount: _properties.length,
                      itemBuilder: (context, index) {
                        final property = _properties[index];
                        return ListTile(
                          title: Text(property['title'] ?? 'Untitled Property'),
                          subtitle: Text(property['status'] ?? 'No status'),
                          trailing: property['isVerified'] == true
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : const Icon(Icons.pending, color: Colors.orange),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PropertyVerificationScreen(
                                  property: property,
                                  onVerificationComplete: _loadProperties,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const Gap(isWidth: false, isHeight: true, height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Gap(isWidth: false, isHeight: true, height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 