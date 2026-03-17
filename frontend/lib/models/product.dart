import 'dart:math';

import 'package:flutter/material.dart';

class Product {
  final int id;
  final String title;
  final String description;
  final String detailedDescription;
  final List<String> images;
  final List<Color> colors;
  final double rating;
  final double price;
  final bool isFavourite;
  final bool isPopular;

  Product({
    required this.id,
    required this.images,
    required this.colors,
    this.rating = 0.0,
    this.isFavourite = false,
    this.isPopular = false,
    required this.title,
    required this.price,
    required this.description,
    required this.detailedDescription,
  });

  /// Primary image to show in the UI.
  ///
  /// Falls back to a default asset based on the product ID if no images are provided.
  String get primaryImage {
    if (images.isNotEmpty) return images.first;
    return getImageByProductId(id);
  }

  /// Returns a per-product default image path by id.
  ///
  /// This is used when a product has no images provided (e.g. backend response
  /// missing image data) but we still want a unique asset per product.
  static String getImageByProductId(int id) {
    const defaultImages = [
      'assets/images/capcut-logo.jpg',
      'assets/images/Adobe_After_Effects_logo.png',
      'assets/images/filmora_logo.png',
    ];

    if (id <= 0) return defaultImages.first;

    // Cycle through our default image set so different products get different
    // placeholder artwork even if their IDs are outside of the small sample range.
    final index = (id - 1) % defaultImages.length;
    return defaultImages[index];
  }

  /// A short description for list/detail headers.
  String get shortDescription {
    if (description.isNotEmpty) return description;
    return _defaultShortDescriptionForId(id);
  }

  /// A longer description shown in the "Detailed information" section.
  String get detailedDescriptionOrDefault {
    if (detailedDescription.isNotEmpty) return detailedDescription;
    return _defaultDetailedDescriptionForId(id);
  }

  static String _defaultShortDescriptionForId(int id) {
    const descriptions = {
      1: 'A powerful and easy-to-use video editing app for creators.',
      2: 'A professional tool for motion graphics and visual effects.',
      3: 'A user-friendly video editor with advanced features and effects.',
    };

    return descriptions[id] ?? 'A great tool for creators.';
  }

  static String _defaultDetailedDescriptionForId(int id) {
    const details = {
      1:
          'CapCut offers advanced editing tools, transitions, and effects, making it perfect for social media content creators.',
      2:
          'Used by professionals worldwide, After Effects allows you to create cinematic visual effects and motion graphics.',
      3:
          'Filmora combines simplicity and power, offering a wide range of editing tools, templates, and visual effects.',
    };

    return details[id] ?? 'No additional information is available for this product.';
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // Backend may use different naming conventions
    final id = json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0;
    final name = json['name'] ?? json['title'] ?? '';
    final description = json['description'] ?? '';
    final detailedDescription = json['detailed_description'] ?? json['details'] ?? description;

    final dynamic imageField = json['image'] ?? json['image_url'] ?? json['images'];
    List<String> images = [];

    if (imageField is String && imageField.isNotEmpty) {
      images = [imageField];
    } else if (imageField is List) {
      images = imageField
          .whereType<String>()
          .where((path) => path.isNotEmpty)
          .toList();
    }

    // If backend did not provide images, fall back to a per-product default.
    if (images.isEmpty) {
      images = [getImageByProductId(id)];
    }

    // Ensure price is double
    double price = 0.0;
    if (json['price'] is num) {
      price = (json['price'] as num).toDouble();
    } else if (json['price'] != null) {
      price = double.tryParse(json['price'].toString()) ?? 0.0;
    }

    double rating = 0.0;
    if (json['rating'] is num) {
      rating = (json['rating'] as num).toDouble();
    } else if (json['rating'] != null) {
      rating = double.tryParse(json['rating'].toString()) ?? 0.0;
    }

    final bool available = json['available'] == true;

    // If backend does not provide rating, we can generate a stable pseudo-random rating.
    final effectiveRating = rating > 0 ? rating : (min(5, (id % 5) + 3) + 0.4);

    return Product(
      id: id,
      title: name.toString(),
      description: description.toString(),
      detailedDescription: detailedDescription.toString(),
      price: price,
      rating: effectiveRating,
      images: images,
      colors: const [
        Color(0xFFF6625E),
        Color(0xFF836DB8),
        Color(0xFFDECB9C),
        Colors.white,
      ],
      isFavourite: false,
      isPopular: available,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title,
      'description': description,
      'detailed_description': detailedDescription,
      'price': price,
      'rating': rating,
      'image': images.isNotEmpty ? images.first : null,
      'images': images,
      'available': isPopular,
    };
  }
}

// Our demo Products

List<Product> demoProducts = [
  Product(
    id: 1,
    images: [
      "assets/images/capcut-logo.jpg",
    ],
    colors: [
      const Color(0xFFF6625E),
      const Color(0xFF836DB8),
      const Color(0xFFDECB9C),
      Colors.white,
    ],
    title: "CapCut",
    price: 0.0,
    description: "A powerful and easy-to-use video editing app for creators.",
    detailedDescription:
        "CapCut offers advanced editing tools, transitions, and effects, making it perfect for social media content creators.",
    rating: 4.7,
    isFavourite: true,
    isPopular: true,
  ),
  Product(
    id: 2,
    images: [
      "assets/images/Adobe_After_Effects_logo.png",
    ],
    colors: [
      const Color(0xFFF6625E),
      const Color(0xFF836DB8),
      const Color(0xFFDECB9C),
      Colors.white,
    ],
    title: "Adobe After Effects",
    price: 19.99,
    description: "A professional tool for motion graphics and visual effects.",
    detailedDescription:
        "Used by professionals worldwide, After Effects allows you to create cinematic visual effects and motion graphics.",
    rating: 4.8,
    isFavourite: false,
    isPopular: true,
  ),
  Product(
    id: 3,
    images: [
      "assets/images/filmora_logo.png",
    ],
    colors: [
      const Color(0xFFF6625E),
      const Color(0xFF836DB8),
      const Color(0xFFDECB9C),
      Colors.white,
    ],
    title: "Filmora",
    price: 39.99,
    description: "A user-friendly video editor with advanced features and effects.",
    detailedDescription:
        "Filmora combines simplicity and power, offering a wide range of editing tools, templates, and visual effects.",
    rating: 4.4,
    isFavourite: true,
    isPopular: true,
  ),
];


