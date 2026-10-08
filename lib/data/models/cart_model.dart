import 'product_model.dart';

class CartItem {
  final ProductModel product;
  final int quantity;
  final String? notes;

  const CartItem({
    required this.product,
    this.quantity = 1,
    this.notes,
  });

  double get totalPrice => product.effectivePrice * quantity;

  CartItem copyWith({int? quantity, String? notes}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }
}

class Cart {
  final String vendorId;
  final String vendorName;
  final double deliveryFee;
  final List<CartItem> items;

  const Cart({
    required this.vendorId,
    required this.vendorName,
    this.deliveryFee = 0,
    this.items = const [],
  });

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.totalPrice);

  double get total => subtotal + deliveryFee;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  Cart copyWith({List<CartItem>? items, double? deliveryFee}) {
    return Cart(
      vendorId: vendorId,
      vendorName: vendorName,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      items: items ?? this.items,
    );
  }
}
