import 'package:flutter/material.dart';
import '../../../components/product_card.dart';
import '../../../models/Product.dart';
import '../../details/details_screen.dart';
import '../../products/products_screen.dart';
import 'section_title.dart';

class PopularProducts extends StatefulWidget {
  const PopularProducts({super.key});

  @override
  State<PopularProducts> createState() => _PopularProductsState();
}

class _PopularProductsState extends State<PopularProducts> {
  @override
  Widget build(BuildContext context) {
    final popularProducts = demoProducts.where((p) => p.isPopular).toList();
    
    if (popularProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionTitle(
            title: "Popular Products",
            press: () {
              Navigator.pushNamed(context, ProductsScreen.routeName);
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: popularProducts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 20 : 10,
                  right: index == popularProducts.length - 1 ? 20 : 0,
                ),
                child: ProductCard(
                  product: popularProducts[index],
                  onPress: () {
                    Navigator.pushNamed(
                      context,
                      DetailsScreen.routeName,
                      arguments: ProductDetailsArguments(
                        product: popularProducts[index],
                      ),
                    );
                  },
                  onFavoriteToggle: () {
                    setState(() {
                      final productIndex = demoProducts.indexWhere(
                        (p) => p.id == popularProducts[index].id
                      );
                      if (productIndex != -1) {
                        demoProducts[productIndex] = demoProducts[productIndex].copyWith(
                          isFavourite: !demoProducts[productIndex].isFavourite,
                        );
                      }
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

