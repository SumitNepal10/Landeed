import 'package:flutter/material.dart';
import 'package:landeed/components/home/property_card.dart';
import 'package:landeed/models/property.dart';
import 'package:landeed/services/auth_service.dart';
import 'package:landeed/services/property_service.dart';
import 'package:provider/provider.dart';

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  late final PropertyService _propertyService;
  final AuthService _authService = AuthService();
  List<Property> _properties = [];
  bool _isLoading = true;
  String? _error;

  // Filter/search state
  String? _filterType;
  String? _filterPurpose;
  String? _filterStatus;
  String? _filterLocation;
  double? _minPrice;
  double? _maxPrice;

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
      final properties = await _propertyService.getAllProperties(
        type: _filterType,
        purpose: _filterPurpose,
        status: _filterStatus,
        location: _filterLocation,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      );
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
        title: const Text('Properties'),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.house_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No properties found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'There are no properties available at the moment',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProperties,
                      child: Column(
                        children: [
                          // Filter/Search UI
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: Column(
                              children: [
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Search by location',
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _filterLocation = value;
                                    });
                                    _loadProperties();
                                  },
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButton<String>(
                                        value: _filterType,
                                        hint: const Text('Type'),
                                        isExpanded: true,
                                        items: ['Land', 'House', 'Apartment', 'Flat']
                                            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() => _filterType = value);
                                          _loadProperties();
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: DropdownButton<String>(
                                        value: _filterPurpose,
                                        hint: const Text('Purpose'),
                                        isExpanded: true,
                                        items: ['Sale', 'Rent']
                                            .map((purpose) => DropdownMenuItem(value: purpose, child: Text(purpose)))
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() => _filterPurpose = value);
                                          _loadProperties();
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: DropdownButton<String>(
                                        value: _filterStatus,
                                        hint: const Text('Status'),
                                        isExpanded: true,
                                        items: ['pending', 'verified', 'rejected']
                                            .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() => _filterStatus = value);
                                          _loadProperties();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: _properties.length,
                              itemBuilder: (context, index) {
                                return PropertyCard(property: _properties[index]);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
} 