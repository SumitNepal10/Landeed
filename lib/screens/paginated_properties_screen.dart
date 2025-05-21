import 'package:flutter/material.dart';
import 'package:landeed/models/property.dart';
import 'package:landeed/services/property_service.dart';
import 'package:landeed/services/auth_service.dart';
import 'package:landeed/components/property_card.dart';

class PaginatedPropertiesScreen extends StatefulWidget {
  const PaginatedPropertiesScreen({Key? key}) : super(key: key);

  @override
  State<PaginatedPropertiesScreen> createState() => _PaginatedPropertiesScreenState();
}

class _PaginatedPropertiesScreenState extends State<PaginatedPropertiesScreen> {
  final List<Property> _properties = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 5;
  late final PropertyService _propertyService;
  String? _error;

  @override
  void initState() {
    super.initState();
    _propertyService = PropertyService(AuthService());
    _fetchProperties();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoading && _hasMore) {
      _fetchProperties();
    }
  }

  Future<void> _fetchProperties() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final properties = await _propertyService.getAllProperties();
      // Ensure properties is a List<Property>
      final List<Property> propertyList = properties is List<Property>
          ? properties
          : properties.map<Property>((e) => Property.fromJson(e as Map<String, dynamic>)).toList();
      final start = _currentPage * _pageSize;
      final end = start + _pageSize;
      final batch = propertyList.length > start ? propertyList.sublist(start, end > propertyList.length ? propertyList.length : end) : <Property>[];
      setState(() {
        _properties.addAll(batch);
        _isLoading = false;
        _hasMore = batch.length == _pageSize;
        if (_hasMore) _currentPage++;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load properties.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Properties')),
      body: _error != null
          ? Center(child: Text(_error!))
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _properties.clear();
                  _currentPage = 0;
                  _hasMore = true;
                });
                await _fetchProperties();
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _properties.length + (_isLoading || _hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _properties.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: PropertyCard(property: _properties[index]),
                    );
                  } else if (_isLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (!_hasMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text('No more properties.')),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
    );
  }
} 