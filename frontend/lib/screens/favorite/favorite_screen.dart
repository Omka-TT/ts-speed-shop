import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ts_speed_shop/components/product_card.dart';
import 'package:ts_speed_shop/models/Product.dart';
import 'package:ts_speed_shop/providers/favorites_provider.dart';
import 'package:ts_speed_shop/services/product_service.dart';

class FavoriteScreen extends StatefulWidget {
  static const String routeName = '/favorites';

  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late final ProductService _productService;
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _productService = ProductService();
    _futureProducts = _productService.getProducts();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureProducts = _productService.getProducts();
    });
    await _futureProducts;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Text(
              'Favorites',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<Product>>(
                future: _futureProducts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Unable to load favorites.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  final allProducts = snapshot.data ?? [];
                  final favorites =
                      context.watch<FavoritesProvider>().favoriteIds;
                  final favoriteProducts = allProducts
                      .where((product) => favorites.contains(product.id))
                      .toList();

                  if (favoriteProducts.isEmpty) {
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
                      itemCount: favoriteProducts.length,
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.95,
                      ),
                      itemBuilder: (context, index) {
                        final product = favoriteProducts[index];
                        return ProductCard(
                          product: product,
                          aspectRatio: 1.05,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


