import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/property.dart';

class FavoritesService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final String _key = 'favorites';
  List<Property> _favorites = [];

  List<Property> get favorites => _favorites;

  FavoritesService() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final favoritesJson = await _storage.read(key: _key);
      if (favoritesJson != null) {
        final List<dynamic> decoded = json.decode(favoritesJson);
        _favorites = decoded.map((item) => Property(
          id: item['id'],
          imageUrl: item['imageUrl'],
          type: item['type'],
          isSale: item['isSale'],
          price: item['price'].toDouble(),
          location: item['location'],
          isFavorite: true,
        )).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final favoritesJson = json.encode(_favorites.map((property) => {
        'id': property.id,
        'imageUrl': property.imageUrl,
        'type': property.type,
        'isSale': property.isSale,
        'price': property.price,
        'location': property.location,
      }).toList());
      await _storage.write(key: _key, value: favoritesJson);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  void toggleFavorite(Property property) {
    final index = _favorites.indexWhere((p) => p.id == property.id);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(property.copyWith(isFavorite: true));
    }
    _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(String propertyId) {
    return _favorites.any((property) => property.id == propertyId);
  }
} 