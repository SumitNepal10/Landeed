import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:landeed/services/property_service.dart';
import 'package:landeed/services/auth_service.dart';
import 'package:landeed/components/property_card.dart';
import 'package:landeed/models/property.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({Key? key}) : super(key: key);

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  late final PropertyService _propertyService;
  List<Map<String, dynamic>> _properties = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _propertyService = PropertyService(
      Provider.of<AuthService>(context, listen: false),
    );
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final properties = await _propertyService.getUserProperties();
      setState(() {
        _properties = properties;
        _isLoading = false;
      });
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
        title: const Text('My Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProperties,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading properties...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $_error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadProperties,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _properties.isEmpty
                  ? const Center(
                      child: Text(
                        'No properties found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProperties,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _properties.length,
                        itemBuilder: (context, index) {
                          final property = _properties[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: PropertyCard(
                              property: Property(
                                id: property['_id'] ?? '',
                                title: property['title'] ?? '',
                                description: property['description'] ?? '',
                                price: double.tryParse(property['price']?.toString() ?? '0') ?? 0.0,
                                location: property['location'] ?? '',
                                images: List<String>.from(property['images'] ?? []),
                                propertyType: property['type'] ?? '',
                                status: property['status'] ?? 'pending',
                                bedrooms: int.tryParse(property['roomDetails']?['bedrooms']?.toString() ?? '0') ?? 0,
                                bathrooms: int.tryParse(property['roomDetails']?['bathrooms']?.toString() ?? '0') ?? 0,
                                area: double.tryParse(property['size']?.toString() ?? '0') ?? 0.0,
                                features: List<String>.from(property['features']?.keys ?? []),
                                userId: property['user']?['_id'],
                                createdAt: DateTime.parse(property['createdAt'] ?? DateTime.now().toIso8601String()),
                                updatedAt: DateTime.parse(property['updatedAt'] ?? DateTime.now().toIso8601String()),
                                isSale: property['purpose'] == 'Sale',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
} 