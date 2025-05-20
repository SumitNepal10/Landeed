import 'package:flutter/foundation.dart';
import '../models/property.dart';

class FavoritesService extends ChangeNotifier {
  final List<Property> _favoriteProperties = [];

  List<Property> get favoriteProperties => _favoriteProperties;

  bool isFavorite(String propertyId) {
    return _favoriteProperties.any((property) => property.id == propertyId);
  }

  void toggleFavorite(Property property) {
    final index = _favoriteProperties.indexWhere((p) => p.id == property.id);
    if (index >= 0) {
      _favoriteProperties.removeAt(index);
    } else {
      _favoriteProperties.add(property);
    }
    notifyListeners();
  }
} 