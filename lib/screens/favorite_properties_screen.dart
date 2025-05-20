import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:landeed/models/property.dart';
import 'package:landeed/services/property_service.dart';
import 'package:landeed/services/auth_service.dart';
import 'package:landeed/screens/property_description_screen.dart';

class FavoritePropertiesScreen extends StatefulWidget {
  const FavoritePropertiesScreen({super.key});

  @override
  State<FavoritePropertiesScreen> createState() => _FavoritePropertiesScreenState();
}

class _FavoritePropertiesScreenState extends State<FavoritePropertiesScreen> {
  List<Property> _favorites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userEmail = authService.userData?['email'];
      if (userEmail == null) throw Exception('User email not found');
      final propertyService = PropertyService(authService);
      final favorites = await propertyService.getFavoriteProperties(userEmail);
      print('Fetched favorites: ' + favorites.map((f) => f.title).toList().toString());
      setState(() {
        _favorites = favorites;
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
        title: const Text('Favorite Properties'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _favorites.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border, size: 64, color: Colors.purple),
                          SizedBox(height: 16),
                          Text('No favorites yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text('Start adding properties to your favorites', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFavorites,
                      child: ListView.separated(
                        itemCount: _favorites.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final property = _favorites[index];
                          return ListTile(
                            leading: property.images.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      property.images.first,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.home, size: 32, color: Colors.grey),
                                  ),
                            title: Text(property.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                              'RS. ${property.price.toStringAsFixed(0)}\n${property.location}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PropertyDescriptionScreen(
                                    propertyId: property.id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
    );
  }
} 