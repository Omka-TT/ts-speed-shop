import 'package:flutter/material.dart';
import 'package:ts_speed_shop/components/product_card.dart';
import 'package:ts_speed_shop/models/Product.dart';
import 'package:ts_speed_shop/screens/sign_in/sign_in_screen.dart';
import 'package:ts_speed_shop/screens/home/components/search_field.dart';
import 'package:ts_speed_shop/services/product_service.dart';


class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  static String routeName = "/products";

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late final ProductService _productService;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  Object? _error;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _productService = ProductService();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await _productService.getProducts();
      _allProducts = products;
      _applyFilter(_searchController.text);
    } catch (e) {
      _error = e;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshProducts() async {
    await _loadProducts();
  }

  void _applyFilter(String query) {
    final lower = query.trim().toLowerCase();

    setState(() {
      if (lower.isEmpty) {
        _filteredProducts = List<Product>.from(_allProducts);
      } else {
        _filteredProducts = _allProducts
            .where((product) => product.title.toLowerCase().contains(lower))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              SearchField(
                controller: _searchController,
                hintText: 'Search for products',
                onChanged: _applyFilter,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshProducts,
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      if (_error is AuthException) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            SignInScreen.routeName,
            (route) => false,
          );
        });

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              (_error as AuthException).message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[700]),
            ),
          ),
        );
      }

      return _ErrorState(
        error: _error,
        onRetry: _refreshProducts,
      );
    }

    if (_filteredProducts.isEmpty) {
      return const _NoResultsState();
    }

    return GridView.builder(
      itemCount: _filteredProducts.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        childAspectRatio: 0.7,
        mainAxisSpacing: 20,
        crossAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return ProductCard(product: product);
      },
    );
  }
}

class _NoResultsState extends StatelessWidget {
  const _NoResultsState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 56,
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 14),
            Text(
              'No products found',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try another keyword or clear the search.',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    Key? key,
    required this.error,
    required this.onRetry,
  }) : super(key: key);

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load products.',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Please check your connection and try again.',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}


