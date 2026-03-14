import 'Product.dart';

class Cart {
  final Product product;
  final int numOfItem;

  Cart({required this.product, required this.numOfItem});

  // Фабричный метод для создания из JSON
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      product: Product.fromJson(json['product'] ?? {}),
      numOfItem: json['numOfItem'] ?? 1,
    );
  }

  // Метод для конвертации в JSON
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'numOfItem': numOfItem,
    };
  }

  // Метод для создания копии
  Cart copyWith({Product? product, int? numOfItem}) {
    return Cart(
      product: product ?? this.product,
      numOfItem: numOfItem ?? this.numOfItem,
    );
  }
  
  // Общая стоимость для этого товара
  double get totalPrice => product.price * numOfItem;
}

// Глобальный список корзины
List<Cart> demoCarts = [];

// Функции для работы с корзиной
void addToCart(Product product, int quantity) {
  final existingIndex = demoCarts.indexWhere((item) => item.product.id == product.id);
  
  if (existingIndex >= 0) {
    demoCarts[existingIndex] = Cart(
      product: product,
      numOfItem: demoCarts[existingIndex].numOfItem + quantity,
    );
  } else {
    demoCarts.add(Cart(product: product, numOfItem: quantity));
  }
}

void removeFromCart(int productId) {
  demoCarts.removeWhere((item) => item.product.id == productId);
}

void updateCartQuantity(int productId, int newQuantity) {
  final index = demoCarts.indexWhere((item) => item.product.id == productId);
  if (index != -1) {
    if (newQuantity <= 0) {
      removeFromCart(productId);
    } else {
      demoCarts[index] = Cart(
        product: demoCarts[index].product,
        numOfItem: newQuantity,
      );
    }
  }
}

void clearCart() {
  demoCarts.clear();
}

double getCartTotal() {
  return demoCarts.fold(0, (total, item) => total + item.totalPrice);
}

int getCartItemCount() {
  return demoCarts.fold(0, (count, item) => count + item.numOfItem);
}

