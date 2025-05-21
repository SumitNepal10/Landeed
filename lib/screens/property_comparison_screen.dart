import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/property.dart';
import '../providers/property_provider.dart';

class PropertyComparisonScreen extends StatefulWidget {
  const PropertyComparisonScreen({super.key});

  @override
  State<PropertyComparisonScreen> createState() => _PropertyComparisonScreenState();
}

class _PropertyComparisonScreenState extends State<PropertyComparisonScreen> {
  List<Property> selectedProperties = [];
  bool _isLoading = true;
  String? _error;
  bool _initialized = false;
  int _step = 1; // 1: select, 2: compare
  Property? _currentProperty;
  Property? _selectedToCompare;
  List<Property> _sameTypeProperties = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _initializeProperties();
    }
  }

  Future<void> _initializeProperties() async {
    try {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['property'] == null || args['property'] is! Property) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _isLoading = false;
            _error = 'No property provided for comparison';
          });
        });
        return;
      }
      final property = args['property'] as Property;
      _currentProperty = property;
      final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
      if (propertyProvider.properties.isEmpty) {
        await propertyProvider.getAllProperties();
      }
      final matches = propertyProvider.properties.where(
        (p) => p.type == property.type && p.id != property.id,
      ).toList();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _sameTypeProperties = matches;
          _isLoading = false;
        });
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load properties: ${e.toString()}';
        });
      });
    }
  }

  void _onPropertySelected(Property property) {
    setState(() {
      _selectedToCompare = property;
      _step = 2;
    });
  }

  void _goBackToSelection() {
    setState(() {
      _step = 1;
      _selectedToCompare = null;
    });
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
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(_error!)),
      );
    }
    if (_step == 1) {
      // Step 1: Property selection
      return Scaffold(
        appBar: AppBar(title: const Text('Select Property to Compare')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Comparing with:', style: Theme.of(context).textTheme.titleMedium),
            ),
            _currentProperty != null
                ? Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: _currentProperty!.images.isNotEmpty
                          ? Image.network(_currentProperty!.images[0], width: 56, height: 56, fit: BoxFit.cover)
                          : const Icon(Icons.home, size: 56),
                      title: Text(_currentProperty!.title),
                      subtitle: Text(_currentProperty!.location),
                    ),
                  )
                : const SizedBox.shrink(),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Select another property of the same type:', style: Theme.of(context).textTheme.titleMedium),
            ),
            Expanded(
              child: _sameTypeProperties.isEmpty
                  ? const Center(child: Text('No other properties of this type found.'))
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _sameTypeProperties.length,
                      itemBuilder: (context, index) {
                        final property = _sameTypeProperties[index];
                        return GestureDetector(
                          onTap: () => _onPropertySelected(property),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: property.images.isNotEmpty
                                      ? Image.network(property.images[0], height: 100, width: double.infinity, fit: BoxFit.cover)
                                      : Container(height: 100, color: Colors.grey[300], child: const Icon(Icons.home, size: 48)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(property.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(property.location, style: const TextStyle(color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      Text('\$${property.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    } else {
      // Step 2: Side-by-side beautiful comparison
      return Scaffold(
        appBar: AppBar(
          title: const Text('Compare Properties'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBackToSelection,
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: isWide
                  ? Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildPropertyCard(_currentProperty!)),
                            Container(
                              alignment: Alignment.center,
                              child: const Icon(Icons.compare_arrows, size: 40, color: Colors.blueAccent),
                            ),
                            Expanded(child: _buildPropertyCard(_selectedToCompare!)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView(
                            children: [
                              _buildAttributeRow('Price',
                                  '\$${_currentProperty!.price.toStringAsFixed(2)}', '\$${_selectedToCompare!.price.toStringAsFixed(2)}', Icons.attach_money),
                              _buildAttributeRow('Location',
                                  _currentProperty!.location, _selectedToCompare!.location, Icons.location_on),
                              _buildAttributeRow('Area',
                                  '${_currentProperty!.area} sq ft', '${_selectedToCompare!.area} sq ft', Icons.square_foot),
                              _buildAttributeRow('Bedrooms',
                                  _currentProperty!.bedrooms.toString(), _selectedToCompare!.bedrooms.toString(), Icons.bed),
                              _buildAttributeRow('Bathrooms',
                                  _currentProperty!.bathrooms.toString(), _selectedToCompare!.bathrooms.toString(), Icons.bathtub),
                              _buildAttributeRow('Year Built',
                                  _currentProperty!.yearBuilt.toString(), _selectedToCompare!.yearBuilt.toString(), Icons.calendar_today),
                              ..._buildFeatureRows(_currentProperty!, _selectedToCompare!),
                            ],
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildPropertyCard(_currentProperty!),
                          const SizedBox(height: 8),
                          const Icon(Icons.compare_arrows, size: 40, color: Colors.blueAccent),
                          const SizedBox(height: 8),
                          _buildPropertyCard(_selectedToCompare!),
                          const SizedBox(height: 16),
                          _buildAttributeRow('Price',
                              '\$${_currentProperty!.price.toStringAsFixed(2)}', '\$${_selectedToCompare!.price.toStringAsFixed(2)}', Icons.attach_money),
                          _buildAttributeRow('Location',
                              _currentProperty!.location, _selectedToCompare!.location, Icons.location_on),
                          _buildAttributeRow('Area',
                              '${_currentProperty!.area} sq ft', '${_selectedToCompare!.area} sq ft', Icons.square_foot),
                          _buildAttributeRow('Bedrooms',
                              _currentProperty!.bedrooms.toString(), _selectedToCompare!.bedrooms.toString(), Icons.bed),
                          _buildAttributeRow('Bathrooms',
                              _currentProperty!.bathrooms.toString(), _selectedToCompare!.bathrooms.toString(), Icons.bathtub),
                          _buildAttributeRow('Year Built',
                              _currentProperty!.yearBuilt.toString(), _selectedToCompare!.yearBuilt.toString(), Icons.calendar_today),
                          ..._buildFeatureRows(_currentProperty!, _selectedToCompare!),
                        ],
                      ),
                    ),
            );
          },
        ),
      );
    }
  }

  Widget _buildPropertyCard(Property property) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: property.images.isNotEmpty
                  ? Image.network(property.images[0], height: 80, width: 120, fit: BoxFit.cover)
                  : Container(height: 80, width: 120, color: Colors.grey[300], child: const Icon(Icons.home, size: 48)),
            ),
            const SizedBox(height: 8),
            Text(property.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(property.location, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeRow(String label, String value1, String value2, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 22),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Center(
              child: Text(value1, style: const TextStyle(color: Colors.black87)),
            ),
          ),
          const Icon(Icons.compare_arrows, color: Colors.grey, size: 18),
          Expanded(
            child: Center(
              child: Text(value2, style: const TextStyle(color: Colors.black87)),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeatureRows(Property p1, Property p2) {
    // Gather all unique feature keys from both properties
    final Set<String> featureKeys = {
      ...?((p1.features is Map) ? (p1.features as Map<String, dynamic>).keys : (p1.features is List ? List<String>.from(p1.features) : [])),
      ...?((p2.features is Map) ? (p2.features as Map<String, dynamic>).keys : (p2.features is List ? List<String>.from(p2.features) : [])),
    };
    if (featureKeys.isEmpty) return [];
    return featureKeys.map((key) {
      final v1 = (p1.features is Map) ? (p1.features as Map)[key] : (p1.features is List && (p1.features as List).contains(key) ? 'Yes' : '-');
      final v2 = (p2.features is Map) ? (p2.features as Map)[key] : (p2.features is List && (p2.features as List).contains(key) ? 'Yes' : '-');
      return _buildAttributeRow(
        _capitalize(key),
        v1?.toString() ?? '-',
        v2?.toString() ?? '-',
        Icons.check_box,
      );
    }).toList();
  }

  String _capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1).replaceAll('_', ' ') : s;
} 