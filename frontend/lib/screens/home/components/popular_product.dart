import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../components/product_card.dart';
import '../../../models/Product.dart'; // Добавлен импорт
import '../../../providers/product_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../details/details_screen.dart';
import '../../products/products_screen.dart';
import 'section_title.dart';

class PopularProducts extends StatelessWidget {
  const PopularProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final popularProducts = productProvider.popularProducts;
        
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
                        productProvider.toggleFavorite(popularProducts[index].id);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

