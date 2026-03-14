import 'package:flutter/material.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final List<String> images;
  final List<Color> colors;
  final double rating;
  final double price;
  bool isFavourite;
  final bool isPopular;
  final bool available;
  final int categoryId;

  Product({
    required this.id,
    required this.images,
    required this.colors,
    this.rating = 0.0,
    this.isFavourite = false,
    this.isPopular = false,
    required this.name,
    required this.price,
    required this.description,
    required this.available,
    required this.categoryId,
  });

  // Фабричный метод для создания продукта из JSON (с backend)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unnamed Product',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      description: json['description'] ?? json['name'] ?? 'No description available',
      available: json['available'] ?? true,
      categoryId: json['category'] ?? 1,
      images: _getImagesForProduct(json['name'] ?? ''),
      colors: _getColorsForProduct(json['id'] ?? 0),
      rating: _getRatingForProduct(json['id'] ?? 0),
      isFavourite: false,
      isPopular: json['popular'] ?? false,
    );
  }

  // Метод для создания копии продукта
  Product copyWith({
    int? id,
    String? name,
    double? price,
    String? description,
    List<String>? images,
    List<Color>? colors,
    double? rating,
    bool? isFavourite,
    bool? isPopular,
    bool? available,
    int? categoryId,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      images: images ?? this.images,
      colors: colors ?? this.colors,
      rating: rating ?? this.rating,
      isFavourite: isFavourite ?? this.isFavourite,
      isPopular: isPopular ?? this.isPopular,
      available: available ?? this.available,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  // Метод для конвертации продукта в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price.toString(),
      'description': description,
      'available': available,
      'category': categoryId,
    };
  }

  // Вспомогательные методы
  static List<String> _getImagesForProduct(String productName) {
    String productNameLower = productName.toLowerCase();
    
    if (productNameLower.contains('capcut')) {
      return ["assets/images/capcut-logo.jpg"];
    } else if (productNameLower.contains('after effects') || productNameLower.contains('after')) {
      return ["assets/images/Adobe_After_Effects_CC_icon.svg.png"];
    } else if (productNameLower.contains('filmora')) {
      return ["assets/images/filmora_logo.png"];
    } else if (productNameLower.contains('photoshop')) {
      return ["assets/images/Adobe_Photoshop_logo.png"];
    } else {
      return ["assets/images/placeholder.png"];
    }
  }

  static List<Color> _getColorsForProduct(int id) {
    switch (id) {
      case 1:
        return [
          const Color(0xFFF6625E),
          const Color(0xFF836DB8),
          const Color(0xFFDECB9C),
          Colors.white,
        ];
      case 2:
        return [
          const Color(0xFF6C5CE7),
          const Color(0xFF00B894),
          const Color(0xFFFD79A8),
          Colors.white,
        ];
      case 3:
        return [
          const Color(0xFFE17055),
          const Color(0xFF0984E3),
          const Color(0xFFFDCB6E),
          Colors.white,
        ];
      default:
        return [
          const Color(0xFFF6625E),
          const Color(0xFF836DB8),
          const Color(0xFFDECB9C),
          Colors.white,
        ];
    }
  }

  static double _getRatingForProduct(int id) {
    switch (id) {
      case 1:
        return 4.8;
      case 2:
        return 4.5;
      case 3:
        return 4.2;
      default:
        return 4.0;
    }
  }

  String get title => name;
  String get formattedPrice => "\$${price.toStringAsFixed(2)}";
}

// Глобальный список продуктов
List<Product> demoProducts = [];

// Функция для инициализации продуктов
void initializeDemoProducts(List<Product> products) {
  demoProducts = List.from(products);
}

// Функция для обновления статуса избранного
void toggleFavorite(int productId) {
  final index = demoProducts.indexWhere((p) => p.id == productId);
  if (index != -1) {
    demoProducts[index] = demoProducts[index].copyWith(
      isFavourite: !demoProducts[index].isFavourite,
    );
  }
}

