import 'package:flutter/material.dart';
import 'package:landeed/models/property.dart';
import 'package:landeed/constant/colors.dart';
import 'package:landeed/services/property_service.dart';
import 'package:landeed/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:landeed/screens/chat_screen.dart';
import 'package:landeed/constant/api_constants.dart';

class PropertyDescriptionScreen extends StatefulWidget {
  final Property? property;
  final String? propertyId;

  const PropertyDescriptionScreen({
    super.key,
    this.property,
    this.propertyId,
  });

  @override
  State<PropertyDescriptionScreen> createState() => _PropertyDescriptionScreenState();
}

class _PropertyDescriptionScreenState extends State<PropertyDescriptionScreen> {
  Property? _property;
  bool _isLoading = true;
  String? _error;
  bool _isFavorite = false;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _userEmail = authService.userData?['email'];
    if (widget.property != null) {
      _property = widget.property;
      _isFavorite = widget.property!.isFavorite;
      _isLoading = false;
      _fetchFavoriteStatus();
    } else if (widget.propertyId != null) {
      _fetchProperty(widget.propertyId!);
    } else {
      _error = 'No property data provided.';
      _isLoading = false;
    }
  }

  Future<void> _fetchFavoriteStatus() async {
    if (_property == null || _userEmail == null) return;
    try {
      final propertyService = PropertyService(Provider.of<AuthService>(context, listen: false));
      final favorites = await propertyService.getFavoriteProperties(_userEmail!);
      setState(() {
        _isFavorite = favorites.any((p) => p.id == _property!.id);
      });
    } catch (e) {
      // Optionally handle error
    }
  }

  Future<void> _fetchProperty(String id) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final propertyService = PropertyService(Provider.of<AuthService>(context, listen: false));
      final property = await propertyService.getPropertyById(id);
      setState(() {
        _property = property;
        _isFavorite = false;
        _isLoading = false;
      });
      await _fetchFavoriteStatus();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_property == null) return;
    final authService = Provider.of<AuthService>(context, listen: false);
    final userEmail = authService.userData?['email'];
    if (userEmail == null) return;
    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      final propertyService = PropertyService(Provider.of<AuthService>(context, listen: false));
      await propertyService.toggleFavorite(_property!.id, userEmail);
      // Update the property's favorite status
      setState(() {
        _property = _property!.copyWith(isFavorite: _isFavorite);
      });
    } catch (e) {
      // Revert the UI state if the API call fails
      setState(() {
        _isFavorite = !_isFavorite;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error!)),
      );
    }
    final property = _property!;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Property Image
                Image.network(
                  property.imageUrl,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                // Back Button and Favorite Button
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: const Icon(Icons.compare_arrows, color: Colors.black),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/propertyComparison', // Update this route if you use a named route constant
                                    arguments: {'property': property},
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: Icon(
                                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: _isFavorite ? Colors.red : Colors.black,
                                ),
                                onPressed: _toggleFavorite,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verification Badge
                  if (property.status == 'verified')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Verified by landeed',
                            style: TextStyle(color: Colors.green[900], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Price and Type
                  Text(
                    'RS. ${property.price.toStringAsFixed(0)}${property.status == 'pending' ? '' : ' (Negotiable)'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.type,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Owner Contact
                  if (property.userEmail != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (property.userEmail == _userEmail)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.person, color: Colors.blue, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'This is your own property',
                                    style: TextStyle(color: Colors.blue[900], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Owner\n${property.userEmail}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // TODO: Implement map view
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[900],
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Map View'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Property Description
                  const Text(
                    'More about this property',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.call, color: Colors.blue, size: 28),
                    onPressed: () {
                      // TODO: Implement call functionality
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat, color: Colors.green, size: 28),
                    onPressed: property.userEmail == _userEmail
                        ? null // Disable chat for own properties
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  property: property,
                                  receiverId: property.userEmail!,
                                  receiverEmail: property.userEmail!,
                                  receiverName: property.userEmail!,
                                  userId: _userEmail!,
                                  baseUrl: ApiConstants.baseUrl,
                                ),
                              ),
                            );
                          },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.grey, size: 28),
                    onPressed: () {
                      // TODO: Implement share functionality
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 