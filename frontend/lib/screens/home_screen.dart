import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.products.length,
              itemBuilder: (ctx, i) => ListTile(
                title: Text(provider.products[i].name),
                subtitle: Text('\$${provider.products[i].price}'),
              ),
            ),
    );
  }
}

