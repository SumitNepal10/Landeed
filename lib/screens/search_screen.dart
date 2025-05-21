import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/advanced_search_filter.dart';
import '../providers/property_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showAdvancedFilters = false;
  Map<String, dynamic> _filters = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Properties'),
        actions: [
          IconButton(
            icon: Icon(_showAdvancedFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showAdvancedFilters = !_showAdvancedFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search properties...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                // Handle search
              },
            ),
          ),
          if (_showAdvancedFilters)
            Expanded(
              child: AdvancedSearchFilter(
                initialFilters: _filters,
                onFilterChanged: (filters) {
                  setState(() {
                    _filters = filters;
                  });
                  // Apply filters to search results
                },
              ),
            ),
          if (!_showAdvancedFilters)
            Expanded(
              child: Consumer<PropertyProvider>(
                builder: (context, propertyProvider, child) {
                  // Display filtered properties
                  return ListView.builder(
                    itemCount: propertyProvider.properties.length,
                    itemBuilder: (context, index) {
                      final property = propertyProvider.properties[index];
                      // Return property card
                      return Card(
                        child: ListTile(
                          title: Text(property.title),
                          subtitle: Text('₹${property.price}'),
                          onTap: () {
                            // Navigate to property details
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
