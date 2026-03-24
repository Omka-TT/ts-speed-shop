import 'Product.dart';
import '../helper/utils.dart';

/// Order Item model with safe parsing
class OrderItem {
  final int id;
  final Product product;
  final int quantity;
  final double price;

  OrderItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int? ?? 0,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
      price: parsePrice(json['price']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'price': price,
    };
  }
}

/// Order model with safe parsing
class Order {
  final int id;
  final List<OrderItem> items;
  final double totalPrice;
  final String status;
  final DateTime? createdAt;

  Order({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.status,
    this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final items = itemsJson.map((item) => OrderItem.fromJson(item as Map<String, dynamic>)).toList();

    return Order(
      id: json['id'] as int? ?? 0,
      items: items,
      totalPrice: parsePrice(json['total_price']),
      status: json['status'] as String? ?? 'Unknown',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Order copyWith({
    int? id,
    List<OrderItem>? items,
    double? totalPrice,
    String? status,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}