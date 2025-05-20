import 'package:flutter/material.dart';
import 'package:landeed/components/app_button.dart';
import 'package:landeed/components/gap.dart';
import 'package:landeed/constant/colors.dart';
import 'package:landeed/constant/api_constants.dart';
import 'package:landeed/screens/admin/property_verification_screen.dart';
import 'package:landeed/screens/admin/pending_properties_screen.dart';
import 'package:landeed/services/auth_service.dart';
import 'package:landeed/utils/route_name.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../providers/property_provider.dart';
import '../../providers/notification_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Map<String, dynamic>> _properties = [];
  bool _isLoading = true;
  bool _showProperties = false;
  String _selectedStatus = '';
  String _selectedStatusTitle = '';
  Map<String, int> _stats = {
    'totalUsers': 0,
    'pendingProperties': 0,
    'verifiedProperties': 0,
    'rejectedProperties': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      final adminToken = await authService.getAdminToken();

      if (adminToken == null) {
        throw Exception('Admin token not found');
      }

      final statsResponse = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/statistics'),
        headers: {
          'Authorization': 'Bearer $adminToken',
          'Content-Type': 'application/json',
        },
      );
      
      if (statsResponse.statusCode == 200) {
        final statsData = jsonDecode(statsResponse.body);
        
        int safeParseInt(dynamic value) {
          if (value == null) return 0;
          if (value is int) return value;
          if (value is String) {
            try {
              return int.parse(value);
            } catch (e) {
              return 0;
            }
          }
          return 0;
        }

        setState(() {
          _stats = {
            'totalUsers': safeParseInt(statsData['totalUsers'] ?? 0),
            'pendingProperties': safeParseInt(statsData['pendingPropertiesCount'] ?? 0),
            'verifiedProperties': safeParseInt(statsData['verifiedPropertiesCount'] ?? 0),
            'rejectedProperties': safeParseInt(statsData['rejectedPropertiesCount'] ?? 0),
          };
        });
      } else {
        final error = jsonDecode(statsResponse.body);
        throw Exception(error['message'] ?? 'Failed to load statistics');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadPropertiesByStatus(String status) async {
    try {
      setState(() {
        _isLoading = true;
        _properties = [];
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      final adminToken = await authService.getAdminToken();

      if (adminToken == null) {
        throw Exception('Admin token not found');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/properties/$status'),
        headers: {
          'Authorization': 'Bearer $adminToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _properties = List<Map<String, dynamic>>.from(data);
          _showProperties = true;
          _selectedStatus = status;
          _selectedStatusTitle = status[0].toUpperCase() + status.substring(1);
        });
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to load properties');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleReject() async {
    final reasonController = TextEditingController();
    
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Property'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Enter rejection reason',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, reasonController.text);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (reason != null && reason.isNotEmpty) {
      // Handle rejection logic
      _loadDashboardData();
    }
  }

  void _showAddAdminDialog() {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final nameController = TextEditingController();
    bool isLoading = false;
    String? emailError;
    String? passwordError;
    String? nameError;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Admin'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      errorText: nameError,
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter full name';
                      }
                      if (value.length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: emailError,
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!value.endsWith('@landeed.com')) {
                        return 'Email must end with @landeed.com';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: passwordError,
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm password';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      setState(() {
                        isLoading = true;
                        emailError = null;
                        passwordError = null;
                        nameError = null;
                      });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
                        final adminToken = await authService.getAdminToken();

                        if (adminToken == null) {
                          throw Exception('Admin token not found');
                        }
      
      final response = await http.post(
                          Uri.parse('${ApiConstants.baseUrl}/admin/create'),
                          headers: {
                            'Authorization': 'Bearer $adminToken',
                            'Content-Type': 'application/json',
                          },
                          body: jsonEncode({
                            'email': emailController.text,
                            'password': passwordController.text,
                            'fullName': nameController.text,
                          }),
                        );

                        if (response.statusCode == 201) {
                          if (!mounted) return;
                          Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Admin added successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          final error = jsonDecode(response.body);
                          if (error['message']?.toString().toLowerCase().contains('email') ?? false) {
                            setState(() => emailError = error['message']);
                          } else if (error['message']?.toString().toLowerCase().contains('password') ?? false) {
                            setState(() => passwordError = error['message']);
                          } else if (error['message']?.toString().toLowerCase().contains('name') ?? false) {
                            setState(() => nameError = error['message']);
      } else {
                            throw Exception(error['message'] ?? 'Failed to add admin');
                          }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => isLoading = false);
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadNotifications() async {
    await Provider.of<NotificationProvider>(context, listen: false).getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddAdminDialog,
            tooltip: 'Add New Admin',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadDashboardData();
              setState(() {
                _showProperties = false;
                _selectedStatus = '';
              });
            },
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
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (!_showProperties) ...[
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Dashboard Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                      children: [
                              _buildStatRow(
                                'Total Users',
                                _stats['totalUsers'].toString(),
                                Icons.people,
                                Colors.blue,
                                  onTap: null,
                              ),
                              const Divider(),
                              _buildStatRow(
                                'Pending Properties',
                                _stats['pendingProperties'].toString(),
                                Icons.pending_actions,
                                Colors.orange,
                                  onTap: () => _loadPropertiesByStatus('pending'),
                              ),
                              const Divider(),
                              _buildStatRow(
                                'Verified Properties',
                                _stats['verifiedProperties'].toString(),
                                Icons.verified,
                                Colors.green,
                                  onTap: () => _loadPropertiesByStatus('verified'),
                              ),
                              const Divider(),
                              _buildStatRow(
                                'Rejected Properties',
                                _stats['rejectedProperties'].toString(),
                                Icons.cancel,
                                Colors.red,
                                  onTap: () => _loadPropertiesByStatus('rejected'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ],
                    if (_showProperties) ...[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                setState(() {
                                  _showProperties = false;
                                  _selectedStatus = '';
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$_selectedStatusTitle Properties',
                              style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _properties.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                  'No properties found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                              itemCount: _properties.length,
                      itemBuilder: (context, index) {
                                final property = _properties[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: ListTile(
                                title: Text(property['title'] ?? 'Untitled Property'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(property['location'] ?? 'No location'),
                                        Text('Price: \$${property['price']}'),
                                        if (property['user'] != null) ...[
                                          const SizedBox(height: 4),
                                          Text('Owner: ${property['user']['fullName'] ?? 'Unknown'}'),
                                        ],
                                      ],
                                    ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PropertyVerificationScreen(
                                        property: property,
                                            onVerificationComplete: () {
                                              _loadDashboardData();
                                              _loadPropertiesByStatus(_selectedStatus);
                                            },
                                      ),
                                    ),
                                  );
                                },
                                  ),
                        );
                      },
                    ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
        ),
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