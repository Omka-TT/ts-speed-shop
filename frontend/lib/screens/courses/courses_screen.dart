import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ts_speed_shop/components/product_card.dart';
import 'package:ts_speed_shop/providers/product_provider.dart';
import 'package:ts_speed_shop/screens/sign_in/sign_in_screen.dart';
import 'package:ts_speed_shop/screens/home/components/search_field.dart';
import 'package:ts_speed_shop/services/product_service.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  static String routeName = "/courses";

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Ensure courses are loaded when this screen is first shown.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshCourses() async {
    await context.read<ProductProvider>().refresh();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              SearchField(
                controller: _searchController,
                hintText: 'Search for courses',
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshCourses,
                  child: _buildContent(context.watch<ProductProvider>()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ProductProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = provider.error;
    if (error != null) {
      if (error is AuthException) {
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
              error.message,
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
        error: error,
        onRetry: _refreshCourses,
      );
    }

    final courses = provider.courses;
    final lower = _searchQuery.trim().toLowerCase();
    final filteredCourses = lower.isEmpty
        ? courses
        : courses
            .where((course) => course.title.toLowerCase().contains(lower))
            .toList();

    if (filteredCourses.isEmpty) {
      return const _NoResultsState();
    }

    return GridView.builder(
      itemCount: filteredCourses.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        childAspectRatio: 0.8,
        mainAxisSpacing: 20,
        crossAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final course = filteredCourses[index];
        return ProductCard(product: course);
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
              'No courses found with this name',
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
              'Unable to load courses.',
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