import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/product_card.dart';
import '../../../providers/product_provider.dart';
import '../../products/products_screen.dart';
import 'section_title.dart';

class PopularProducts extends StatelessWidget {
  const PopularProducts({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    final isLoading = provider.isLoading;
    final error = provider.error;
    final popularProducts = provider.products.where((p) => p.isPopular).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionTitle(
            title: 'Popular Products',
            press: () {
              Navigator.pushNamed(context, ProductsScreen.routeName);
            },
          ),
        ),
        SizedBox(
          height: 260,
          child: Builder(
            builder: (context) {
              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (error != null) {
                return Center(
                  child: Text(
                    'Failed to load popular products.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }

              if (popularProducts.isEmpty) {
                return Center(
                  child: Text(
                    'No popular products available.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: popularProducts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final product = popularProducts[index];
                  return ProductCard(product: product);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}


