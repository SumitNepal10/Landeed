import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/favorites_service.dart';
import '../../models/property.dart';

class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({
    super.key,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    final favoritesService = Provider.of<FavoritesService>(context);
    final isFavorite = favoritesService.isFavorite(property.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                property.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: () => favoritesService.toggleFavorite(property),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.type,
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
                Text(
                  property.location,
                  style: Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 3,
                          child: Text(
                            '\$${property.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 2,
                          child: Text(
                            property.isSale ? 'For Sale' : 'For Rent',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
