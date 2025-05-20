import 'package:flutter/material.dart';
import 'package:partice_project/components/app_button.dart';
import 'package:partice_project/components/gap.dart';
import 'package:partice_project/constant/api_constants.dart';
import 'package:partice_project/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PropertyVerificationScreen extends StatefulWidget {
  final Map<String, dynamic> property;
  final VoidCallback onVerificationComplete;

  const PropertyVerificationScreen({
    Key? key,
    required this.property,
    required this.onVerificationComplete,
  }) : super(key: key);

  @override
  State<PropertyVerificationScreen> createState() => _PropertyVerificationScreenState();
}

class _PropertyVerificationScreenState extends State<PropertyVerificationScreen> {
  bool _isLoading = false;
  final _rejectionReasonController = TextEditingController();

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  Future<void> _handleVerification(bool isApprove) async {
    if (!isApprove && _rejectionReasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason for rejection')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final adminToken = await authService.getAdminToken();

      if (adminToken == null) {
        throw Exception('Admin token not found');
      }

      final url = isApprove
          ? '${ApiConstants.baseUrl}/admin/properties/${widget.property['_id']}/approve'
          : '${ApiConstants.baseUrl}/admin/properties/${widget.property['_id']}/reject';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $adminToken',
        },
        body: isApprove ? null : jsonEncode({
          'reason': _rejectionReasonController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isApprove ? 'Property approved successfully' : 'Property rejected successfully'),
            backgroundColor: isApprove ? Colors.green : Colors.orange,
          ),
        );

        // Call the callback to refresh the parent screen
        widget.onVerificationComplete();

        // Navigate back
        Navigator.of(context).pop();
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to verify property');
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildFeatureChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.blue[100],
      labelStyle: TextStyle(color: Colors.blue[900]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Verification'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Images
                  if (widget.property['images'] != null && (widget.property['images'] as List).isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: (widget.property['images'] as List).length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.network(
                              widget.property['images'][index],
                              fit: BoxFit.cover,
                              width: 300,
                            ),
                          );
                        },
                      ),
                    ),
                  const Gap(isWidth: false, isHeight: true, height: 16),

                  // Property Details
                  Text(
                    widget.property['title'],
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Gap(isWidth: false, isHeight: true, height: 8),
                  Text(
                    'Price: \$${widget.property['price']}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Gap(isWidth: false, isHeight: true, height: 8),
                  Text('Location: ${widget.property['location']}'),
                  Text('Type: ${widget.property['type']}'),
                  Text('Purpose: ${widget.property['purpose']}'),
                  Text('Size: ${widget.property['size']}'),
                  const Gap(isWidth: false, isHeight: true, height: 16),

                  // Room Details
                  if (widget.property['roomDetails'] != null) ...[
                    Text(
                      'Room Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Gap(isWidth: false, isHeight: true, height: 8),
                    Text('Bedrooms: ${widget.property['roomDetails']['bedrooms']}'),
                    Text('Bathrooms: ${widget.property['roomDetails']['bathrooms']}'),
                    Text('Kitchens: ${widget.property['roomDetails']['kitchens']}'),
                    Text('Living Rooms: ${widget.property['roomDetails']['livingRooms']}'),
                    const Gap(isWidth: false, isHeight: true, height: 16),
                  ],

                  // Features
                  if (widget.property['features'] != null) ...[
                    Text(
                      'Features',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Gap(isWidth: false, isHeight: true, height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (widget.property['features']['parking']) _buildFeatureChip('Parking'),
                        if (widget.property['features']['garden']) _buildFeatureChip('Garden'),
                        if (widget.property['features']['security']) _buildFeatureChip('Security'),
                        if (widget.property['features']['swimmingPool']) _buildFeatureChip('Swimming Pool'),
                        if (widget.property['features']['airConditioning']) _buildFeatureChip('Air Conditioning'),
                        if (widget.property['features']['furnished']) _buildFeatureChip('Furnished'),
                      ],
                    ),
                    const Gap(isWidth: false, isHeight: true, height: 16),
                  ],

                  // Additional Details
                  if (widget.property['floorLevel'] != null)
                    Text('Floor Level: ${widget.property['floorLevel']}'),
                  if (widget.property['facingDirection'] != null)
                    Text('Facing Direction: ${widget.property['facingDirection']}'),
                  const Gap(isWidth: false, isHeight: true, height: 24),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Gap(isWidth: false, isHeight: true, height: 8),
                  Text(widget.property['description']),
                  const Gap(isWidth: false, isHeight: true, height: 24),

                  // Contact Info
                  Text(
                    'Contact Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Gap(isWidth: false, isHeight: true, height: 8),
                  Text(widget.property['contactInfo']),
                  const Gap(isWidth: false, isHeight: true, height: 24),

                  // Rejection Reason Field
                  TextField(
                    controller: _rejectionReasonController,
                    decoration: const InputDecoration(
                      labelText: 'Rejection Reason (Required for rejection)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const Gap(isWidth: false, isHeight: true, height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _handleVerification(false),
                        child: const Text('Reject'),
                      ),
                      const Gap(isWidth: true, isHeight: false, width: 16),
                      AppButton(
                        title: 'Approve',
                        onPress: () => _handleVerification(true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
} 