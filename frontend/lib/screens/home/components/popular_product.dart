import 'package:flutter/material.dart';

import '../../../components/product_card.dart';
import '../../../models/Product.dart';
import '../../../services/product_service.dart';
import '../../products/products_screen.dart';
import 'section_title.dart';

class PopularProducts extends StatefulWidget {
  const PopularProducts({super.key});

  @override
  State<PopularProducts> createState() => _PopularProductsState();
}

class _PopularProductsState extends State<PopularProducts> {
  late final ProductService _productService;
  late Future<List<Product>> _futurePopular;

  @override
  void initState() {
    super.initState();
    _productService = ProductService();
    _futurePopular = _loadPopular();
  }

  Future<List<Product>> _loadPopular() async {
    final products = await _productService.getProducts();
    return products.where((p) => p.isPopular).toList();
  }

  @override
  Widget build(BuildContext context) {
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
          child: FutureBuilder<List<Product>>(
            future: _futurePopular,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Failed to load popular products.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }

              final products = snapshot.data ?? [];
              if (products.isEmpty) {
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
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final product = products[index];
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


