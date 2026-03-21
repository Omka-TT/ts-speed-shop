import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ts_speed_shop/components/product_card.dart';
import 'package:ts_speed_shop/providers/favorites_provider.dart';

class FavoriteScreen extends StatelessWidget {
  static const String routeName = '/favorites';

  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final favorites = provider.favorites;

          if (favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'You haven\'t favorited any products yet. Tap the heart icon on a product to save it here.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey[700]),
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: favorites.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 18,
                crossAxisSpacing: 16,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final product = favorites[index];
                return ProductCard(product: product);
              },
            ),
          );
        },
      ),
    );
  }
}


