import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/favorites_service.dart';
import '../components/property_card.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesService = Provider.of<FavoritesService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: favoritesService.favoriteProperties.isEmpty
          ? const Center(
              child: Text('No favorite properties yet'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoritesService.favoriteProperties.length,
              itemBuilder: (context, index) {
                final property = favoritesService.favoriteProperties[index];
                return PropertyCard(property: property);
              },
            ),
    );
  }
} 