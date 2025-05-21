import 'package:flutter/material.dart';

class AdvancedSearchFilter extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;
  final Map<String, dynamic> initialFilters;

  const AdvancedSearchFilter({
    super.key,
    required this.onFilterChanged,
    this.initialFilters = const {},
  });

  @override
  State<AdvancedSearchFilter> createState() => _AdvancedSearchFilterState();
}

class _AdvancedSearchFilterState extends State<AdvancedSearchFilter> {
  late Map<String, dynamic> _filters;

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.initialFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Advanced Filters',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Price Range
          _buildPriceRangeFilter(),
          const SizedBox(height: 16),
          // Property Type
          _buildPropertyTypeFilter(),
          const SizedBox(height: 16),
          // Bedrooms
          _buildBedroomsFilter(),
          const SizedBox(height: 16),
          // Bathrooms
          _buildBathroomsFilter(),
          const SizedBox(height: 16),
          // Area Range
          _buildAreaRangeFilter(),
          const SizedBox(height: 16),
          // Amenities
          _buildAmenitiesFilter(),
          const SizedBox(height: 16),
          // Year Built
          _buildYearBuiltFilter(),
          const SizedBox(height: 24),
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onFilterChanged(_filters);
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Price Range'),
        RangeSlider(
          values: RangeValues(
            _filters['minPrice']?.toDouble() ?? 0,
            _filters['maxPrice']?.toDouble() ?? 10000000,
          ),
          min: 0,
          max: 10000000,
          divisions: 100,
          labels: RangeLabels(
            '₹${_filters['minPrice']?.toStringAsFixed(0) ?? '0'}',
            '₹${_filters['maxPrice']?.toStringAsFixed(0) ?? '10000000'}',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _filters['minPrice'] = values.start;
              _filters['maxPrice'] = values.end;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPropertyTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Property Type'),
        Wrap(
          spacing: 8.0,
          children: ['House', 'Apartment', 'Land', 'Commercial'].map((type) {
            final isSelected = _filters['propertyType'] == type;
            return FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filters['propertyType'] = selected ? type : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBedroomsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bedrooms'),
        Wrap(
          spacing: 8.0,
          children: List.generate(6, (index) {
            final isSelected = _filters['bedrooms'] == index;
            return FilterChip(
              label: Text(index == 0 ? 'Studio' : '$index+'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filters['bedrooms'] = selected ? index : null;
                });
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBathroomsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bathrooms'),
        Wrap(
          spacing: 8.0,
          children: List.generate(5, (index) {
            final isSelected = _filters['bathrooms'] == index + 1;
            return FilterChip(
              label: Text('${index + 1}+'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filters['bathrooms'] = selected ? index + 1 : null;
                });
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAreaRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Area Range (sq ft)'),
        RangeSlider(
          values: RangeValues(
            _filters['minArea']?.toDouble() ?? 0,
            _filters['maxArea']?.toDouble() ?? 10000,
          ),
          min: 0,
          max: 10000,
          divisions: 100,
          labels: RangeLabels(
            '${_filters['minArea']?.toStringAsFixed(0) ?? '0'} sq ft',
            '${_filters['maxArea']?.toStringAsFixed(0) ?? '10000'} sq ft',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _filters['minArea'] = values.start;
              _filters['maxArea'] = values.end;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAmenitiesFilter() {
    final amenities = [
      'Parking',
      'Garden',
      'Swimming Pool',
      'Gym',
      'Security',
      'Elevator',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Amenities'),
        Wrap(
          spacing: 8.0,
          children: amenities.map((amenity) {
            final isSelected = (_filters['amenities'] as List?)?.contains(amenity) ?? false;
            return FilterChip(
              label: Text(amenity),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filters['amenities'] ??= [];
                  if (selected) {
                    (_filters['amenities'] as List).add(amenity);
                  } else {
                    (_filters['amenities'] as List).remove(amenity);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildYearBuiltFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Year Built'),
        RangeSlider(
          values: RangeValues(
            _filters['minYear']?.toDouble() ?? 1950,
            _filters['maxYear']?.toDouble() ?? 2024,
          ),
          min: 1950,
          max: 2024,
          divisions: 74,
          labels: RangeLabels(
            '${_filters['minYear']?.toStringAsFixed(0) ?? '1950'}',
            '${_filters['maxYear']?.toStringAsFixed(0) ?? '2024'}',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _filters['minYear'] = values.start;
              _filters['maxYear'] = values.end;
            });
          },
        ),
      ],
    );
  }
} 