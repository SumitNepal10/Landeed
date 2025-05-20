import 'package:flutter/material.dart';
import 'package:landeed/components/home/search_bar.dart';
import 'package:landeed/components/home/category_item.dart';
import 'package:landeed/components/property_card.dart';
import 'package:landeed/models/property.dart';
import 'package:landeed/services/property_service.dart';
import 'package:landeed/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:landeed/screens/property_description_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Apartment';
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentProperties = [];
  List<Map<String, dynamic>> _premiumProperties = [];
  List<Map<String, dynamic>> _topProperties = [];
  late final PropertyService _propertyService;

  // Filter state
  String? _filterType;
  String? _filterPurpose;
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
      setState(() => _isLoading = true);
      List<Map<String, dynamic>> recent = [];
      List<Map<String, dynamic>> premium = [];
      List<Map<String, dynamic>> top = [];
      try {
        recent = await _propertyService.getRecentProperties(
          type: _filterType,
          purpose: _filterPurpose,
          location: _filterLocation,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
        );
      } catch (e) {}
      try {
        premium = await _propertyService.getPremiumProperties(
          type: _filterType,
          purpose: _filterPurpose,
          location: _filterLocation,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
        );
      } catch (e) {}
      try {
        top = await _propertyService.getTopProperties(
          type: _filterType,
          purpose: _filterPurpose,
          location: _filterLocation,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
        );
      } catch (e) {}
      if (mounted) {
        setState(() {
          _recentProperties = recent;
          _premiumProperties = premium;
          _topProperties = top;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading properties: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    final searchQuery = query.toLowerCase();
    if (searchQuery.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PropertySearchResultsScreen(
            initialQuery: searchQuery,
            allProperties: [
              ..._topProperties,
              ..._premiumProperties,
              ..._recentProperties,
            ],
          ),
        ),
      );
    }
  }

  void _handleFilter() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        String? tempType = _filterType;
        String? tempPurpose = _filterPurpose;
        String? tempLocation = _filterLocation;
        double? tempMinPrice = _minPrice;
        double? tempMaxPrice = _maxPrice;
        return AlertDialog(
          title: const Text('Filters'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: tempType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ['Land', 'House', 'Apartment', 'Flat']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => tempType = value,
                ),
                DropdownButtonFormField<String>(
                  value: tempPurpose,
                  decoration: const InputDecoration(labelText: 'Purpose'),
                  items: ['Sale', 'Rent']
                      .map((purpose) => DropdownMenuItem(value: purpose, child: Text(purpose)))
                      .toList(),
                  onChanged: (value) => tempPurpose = value,
                ),
                TextFormField(
                  initialValue: tempLocation,
                  decoration: const InputDecoration(labelText: 'Location'),
                  onChanged: (value) => tempLocation = value,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: tempMinPrice?.toString(),
                        decoration: const InputDecoration(labelText: 'Min Price'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => tempMinPrice = double.tryParse(value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: tempMaxPrice?.toString(),
                        decoration: const InputDecoration(labelText: 'Max Price'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => tempMaxPrice = double.tryParse(value),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'type': tempType,
                  'purpose': tempPurpose,
                  'location': tempLocation,
                  'minPrice': tempMinPrice,
                  'maxPrice': tempMaxPrice,
                });
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      setState(() {
        _filterType = result['type'];
        _filterPurpose = result['purpose'];
        _filterLocation = result['location'];
        _minPrice = result['minPrice'];
        _maxPrice = result['maxPrice'];
      });
      _loadProperties();
    }
  }

  Widget _buildPropertySection(String title, List<Map<String, dynamic>> properties) {
    // Filter properties by search query (title or location)
    final filtered = _searchQuery.isEmpty
        ? properties
        : properties.where((property) {
            final title = (property['title'] ?? '').toString().toLowerCase();
            final location = (property['location'] ?? '').toString().toLowerCase();
            return title.contains(_searchQuery) || location.contains(_searchQuery);
          }).toList();

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
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final property = filtered[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PropertyDescriptionScreen(
                        property: Property.fromJson(property),
                      ),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      width: 220,
                      margin: const EdgeInsets.only(right: 16),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Property Image
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                property['images']?[0] ?? 'https://via.placeholder.com/150',
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 140,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.error_outline),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    property['title'] ?? 'Untitled Property',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    property['location'] ?? 'No location',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '\$${property['price']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.home, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        property['type'] ?? 'Not specified',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(Icons.star, size: 16, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text(
                                        property['propertyClass'] ?? 'Regular',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Favorite Button (top right)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _FavoriteButton(propertyId: property['_id'] ?? property['id']),
                    ),
                  ],
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landeed'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
              // Optionally add notification badge here if needed
            ],
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadProperties,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      CustomSearchBar(
                        searchController: _searchController,
                        onSearch: (query) {},
                        onSubmitted: _handleSearch,
                        onFilterTap: _handleFilter,
                      ),
                      const SizedBox(height: 24),
                      
                      // Top Properties Section
                      if (_topProperties.isNotEmpty) ...[
                        _buildPropertySection('Top Properties', _topProperties),
                        const SizedBox(height: 24),
                      ],

                      // Premium Properties Section
                      if (_premiumProperties.isNotEmpty) ...[
                        _buildPropertySection('Premium Properties', _premiumProperties),
                        const SizedBox(height: 24),
                      ],

                      // Recent Properties Section
                      if (_recentProperties.isNotEmpty) ...[
                        _buildPropertySection('Recent Properties', _recentProperties),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class PropertySearchResultsScreen extends StatefulWidget {
  final String initialQuery;
  final List<Map<String, dynamic>> allProperties;
  const PropertySearchResultsScreen({
    Key? key,
    required this.initialQuery,
    required this.allProperties,
  }) : super(key: key);

  @override
  State<PropertySearchResultsScreen> createState() => _PropertySearchResultsScreenState();
}

class _PropertySearchResultsScreenState extends State<PropertySearchResultsScreen> {
  late TextEditingController _searchController;
  late String _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialQuery;
    _searchController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSubmitted(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _searchQuery.isEmpty
        ? widget.allProperties
        : widget.allProperties.where((property) {
            final title = (property['title'] ?? '').toString().toLowerCase();
            final location = (property['location'] ?? '').toString().toLowerCase();
            return title.contains(_searchQuery) || location.contains(_searchQuery);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search properties...',
            border: InputBorder.none,
          ),
          onSubmitted: _onSubmitted,
        ),
      ),
      body: filtered.isEmpty
          ? const Center(child: Text('No properties found.'))
          : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final property = filtered[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PropertyDescriptionScreen(
                            property: Property.fromJson(property),
                          ),
                        ),
                      );
                    },
                    leading: property['images'] != null && property['images'].isNotEmpty
                        ? Image.network(
                            property['images'][0],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.home, size: 40),
                    title: Text(property['title'] ?? 'Untitled Property'),
                    subtitle: Text(property['location'] ?? ''),
                    trailing: Text(
                      '\$${property['price']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  final String propertyId;
  const _FavoriteButton({required this.propertyId});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  bool _isFavorite = false;
  bool _loading = false;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _userEmail = authService.userData?['email'];
    _fetchFavoriteStatus();
  }

  Future<void> _fetchFavoriteStatus() async {
    if (_userEmail == null) return;
    try {
      final propertyService = PropertyService(Provider.of<AuthService>(context, listen: false));
      final favorites = await propertyService.getFavoriteProperties(_userEmail!);
      setState(() {
        _isFavorite = favorites.any((p) => p.id == widget.propertyId);
      });
    } catch (e) {
      // Optionally handle error
    }
  }

  Future<void> _toggleFavorite() async {
    if (_userEmail == null) return;
    setState(() => _loading = true);
    try {
      final propertyService = PropertyService(Provider.of<AuthService>(context, listen: false));
      await propertyService.toggleFavorite(widget.propertyId, _userEmail!);
      setState(() => _isFavorite = !_isFavorite);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update favorite: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isFavorite ? Icons.favorite : Icons.favorite_border,
        color: _isFavorite ? Colors.red : Colors.grey,
      ),
      onPressed: _loading ? null : _toggleFavorite,
      tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
    );
  }
}
