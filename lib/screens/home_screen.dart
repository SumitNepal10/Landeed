import 'package:flutter/material.dart';
import 'package:partice_project/components/home/search_bar.dart';
import 'package:partice_project/components/home/category_item.dart';
import 'package:partice_project/components/property_card.dart';
import 'package:partice_project/models/property.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Apartment';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _handleFilter() {
    // TODO: Implement filter functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filters'),
        content: const Text('Filter options coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  List<PropertyCard> _filterProperties(List<PropertyCard> properties) {
    if (_searchQuery.isEmpty) return properties;
    
    return properties.where((property) {
      final prop = property.property;
      final query = _searchQuery.toLowerCase();
      return prop.type.toLowerCase().contains(query) ||
             prop.location.toLowerCase().contains(query) ||
             prop.price.toString().contains(query);
    }).toList();
  }

  Widget _buildPropertyList(String title, List<PropertyCard> properties) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == properties.length - 1 ? 0 : 16,
                ),
                child: SizedBox(
                  width: 280,
                  child: properties[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const double sectionSpacing = 24.0;
    const double elementSpacing = 20.0;

    final topProperties = _filterProperties([
      const PropertyCard(
        property: Property(
          id: '1',
          imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6',
          type: 'Modern Villa',
          isSale: true,
          price: 850000,
          location: 'Beverly Hills, CA',
        ),
      ),
      const PropertyCard(
        property: Property(
          id: '2',
          imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
          type: 'Luxury House',
          isSale: false,
          price: 5000,
          location: 'Manhattan, NY',
        ),
      ),
    ]);

    final newProperties = _filterProperties([
      const PropertyCard(
        property: Property(
          id: '3',
          imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9',
          type: 'Family Home',
          isSale: true,
          price: 450000,
          location: 'San Francisco, CA',
        ),
      ),
      const PropertyCard(
        property: Property(
          id: '4',
          imageUrl: 'https://images.unsplash.com/photo-1600585154526-990dced4db0d',
          type: 'Modern House',
          isSale: false,
          price: 3500,
          location: 'Chicago, IL',
        ),
      ),
    ]);

    final premiumProperties = _filterProperties([
      const PropertyCard(
        property: Property(
          id: '5',
          imageUrl: 'https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde',
          type: 'Luxury Villa',
          isSale: true,
          price: 1200000,
          location: 'Miami Beach, FL',
        ),
      ),
      const PropertyCard(
        property: Property(
          id: '6',
          imageUrl: 'https://images.unsplash.com/photo-1600566753376-12c8ab7fb75b',
          type: 'Premium House',
          isSale: true,
          price: 950000,
          location: 'Los Angeles, CA',
        ),
      ),
    ]);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              CustomSearchBar(
                searchController: _searchController,
                onSearch: _handleSearch,
                onFilterTap: _handleFilter,
              ),
              const SizedBox(height: sectionSpacing),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Search Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CategoryItem(
                          title: 'House',
                          icon: Icons.home,
                          backgroundColor: Colors.blue[50]!,
                          isSelected: _selectedCategory == 'House',
                          onTap: () => setState(() => _selectedCategory = 'House'),
                        ),
                        CategoryItem(
                          title: 'Apartment',
                          icon: Icons.apartment,
                          backgroundColor: Colors.green[50]!,
                          isSelected: _selectedCategory == 'Apartment',
                          onTap: () => setState(() => _selectedCategory = 'Apartment'),
                        ),
                        CategoryItem(
                          title: 'Rent',
                          icon: Icons.key,
                          backgroundColor: Colors.purple[50]!,
                          isSelected: _selectedCategory == 'Rent',
                          onTap: () => setState(() => _selectedCategory = 'Rent'),
                        ),
                        CategoryItem(
                          title: 'Land',
                          icon: Icons.landscape,
                          backgroundColor: Colors.pink[50]!,
                          isSelected: _selectedCategory == 'Land',
                          onTap: () => setState(() => _selectedCategory = 'Land'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: sectionSpacing),
              _buildPropertyList('Top Properties', topProperties),
              _buildPropertyList('New Properties', newProperties),
              _buildPropertyList('Premium Properties', premiumProperties),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
