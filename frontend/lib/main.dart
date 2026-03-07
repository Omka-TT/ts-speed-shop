import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Shop',
      home: Scaffold(
        appBar: AppBar(title: Text('Test Shop')),
        body: ProductList(),
      ),
    );
  }
}

class ProductList extends StatefulWidget {
  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List products = [];

  void fetchProducts() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/products/'));
    final data = json.decode(response.body);
    setState(() {
      products = data;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (_, index) {
        return ListTile(
          title: Text(products[index]['name']),
          subtitle: Text('\$${products[index]['price']}'),
        );
      },
    );
  }
}

