import 'package:flutter/material.dart';
import 'package:landeed/components/gap.dart';
import 'package:landeed/constant/api_constants.dart';
import 'package:landeed/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

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
  String _selectedPropertyClass = 'Regular';

  Future<void> _verifyProperty() async {
    try {
      setState(() => _isLoading = true);

      final authService = Provider.of<AuthService>(context, listen: false);
      final adminToken = await authService.getAdminToken();

      if (adminToken == null) {
        throw Exception('Admin token not found');
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/admin/properties/${widget.property['_id']}/verify'),
        headers: {
          'Authorization': 'Bearer $adminToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'propertyClass': _selectedPropertyClass,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Property verified successfully'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onVerificationComplete();
        Navigator.pop(context);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to verify property');
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
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _rejectProperty() async {
    if (_rejectionReasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rejection reason')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final authService = Provider.of<AuthService>(context, listen: false);
      final adminToken = await authService.getAdminToken();

      if (adminToken == null) {
        throw Exception('Admin token not found');
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/admin/properties/${widget.property['_id']}/reject'),
        headers: {
          'Authorization': 'Bearer $adminToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'rejectionReason': _rejectionReasonController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property rejected successfully')),
        );
        widget.onVerificationComplete();
        Navigator.pop(context);
      } else {
        throw Exception('Failed to reject property');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
        ),
    );
  }

  Widget _buildPropertyImage() {
    if (widget.property['images'] == null || (widget.property['images'] as List).isEmpty) {
      return Card(
        elevation: 2,
        child: Container(
          height: 200,
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: SizedBox(
        height: 250,
        child: PageView.builder(
          itemCount: (widget.property['images'] as List).length,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: widget.property['images'][index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.error_outline, size: 50, color: Colors.grey),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Verification'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Property Images
                      _buildPropertyImage(),
                      const Gap(isWidth: false, isHeight: true, height: 16),

                      // Basic Details
                      _buildSection('Property Details', [
                        Text(
                          widget.property['title'] ?? 'Untitled Property',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(isWidth: false, isHeight: true, height: 8),
                        Row(
                          children: [
                            Icon(Icons.attach_money, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            Text(
                              '\$${widget.property['price']}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Gap(isWidth: false, isHeight: true, height: 8),
                        _buildDetailRow(Icons.location_on, widget.property['location']),
                        _buildDetailRow(Icons.category, widget.property['type']),
                        _buildDetailRow(Icons.sell, widget.property['purpose']),
                        _buildDetailRow(Icons.straighten, '${widget.property['size']} sq ft'),
                      ]),

                      // Room Details
                      if (widget.property['roomDetails'] != null)
                        _buildSection('Room Details', [
                          _buildDetailRow(Icons.bed, '${widget.property['roomDetails']['bedrooms']} Bedrooms'),
                          _buildDetailRow(Icons.bathtub, '${widget.property['roomDetails']['bathrooms']} Bathrooms'),
                          _buildDetailRow(Icons.kitchen, '${widget.property['roomDetails']['kitchen']} Kitchen'),
                          _buildDetailRow(Icons.chair, '${widget.property['roomDetails']['livingRoom']} Living Room'),
                          _buildDetailRow(Icons.local_parking, '${widget.property['roomDetails']['parking']} Parking'),
                        ]),

                      // Features
                      if (widget.property['features'] != null)
                        _buildSection('Features', [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (widget.property['features']['furnished'] == true)
                                _buildFeatureChip('Furnished', Icons.chair),
                              if (widget.property['features']['parking'] == true)
                                _buildFeatureChip('Parking', Icons.local_parking),
                              if (widget.property['features']['garden'] == true)
                                _buildFeatureChip('Garden', Icons.grass),
                              if (widget.property['features']['swimmingPool'] == true)
                                _buildFeatureChip('Swimming Pool', Icons.pool),
                            ],
                          ),
                        ]),

                      // Additional Details
                      if (widget.property['floorLevel'] != null || widget.property['facingDirection'] != null)
                        _buildSection('Additional Details', [
                          if (widget.property['floorLevel'] != null)
                            _buildDetailRow(Icons.layers, 'Floor Level: ${widget.property['floorLevel']}'),
                          if (widget.property['facingDirection'] != null)
                            _buildDetailRow(Icons.compass_calibration, 'Facing Direction: ${widget.property['facingDirection']}'),
                        ]),

                      // Description
                      _buildSection('Description', [
                        Text(
                          widget.property['description'] ?? 'No description available',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ]),

                      // Contact Info
                      _buildSection('Contact Information', [
                        Text(
                          widget.property['contactInfo'] ?? 'No contact information available',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ]),

                      // User Information
                      if (widget.property['user'] != null)
                        _buildSection('User Information', [
                          _buildDetailRow(Icons.person, widget.property['user']['fullName'] ?? 'N/A'),
                          _buildDetailRow(Icons.email, widget.property['user']['email'] ?? 'N/A'),
                          _buildDetailRow(Icons.phone, widget.property['user']['phoneNumber'] ?? 'N/A'),
                        ]),

                      // Property Class Selection
                      _buildSection('Property Class', [
                        DropdownButtonFormField<String>(
                          value: _selectedPropertyClass,
                          decoration: const InputDecoration(
                            labelText: 'Select Property Class',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Regular', child: Text('Regular')),
                            DropdownMenuItem(value: 'Premium', child: Text('Premium')),
                            DropdownMenuItem(value: 'Top', child: Text('Top')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedPropertyClass = value;
                              });
                            }
                          },
                        ),
                      ]),

                      // Rejection Reason
                      Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rejection Reason',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const Divider(),
                              TextField(
                                controller: _rejectionReasonController,
                                decoration: const InputDecoration(
                                  labelText: 'Please provide a reason for rejection',
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter rejection reason here...',
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Action Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _verifyProperty,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Verify Property'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _rejectProperty,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                icon: const Icon(Icons.cancel),
                                label: const Text('Reject Property'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Theme.of(context).primaryColor),
      label: Text(label),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
    );
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }
} 