import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/cart_model.dart';
import '../../../data/models/product_model.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  void addToCart({
    required ProductModel product,
    required String vendorId,
    required String vendorName,
    required double deliveryFee,
  }) {
    // If cart has items from a different vendor, clear it
    if (state.cart != null && state.cart!.vendorId != vendorId) {
      _replaceCart(
        vendorId: vendorId,
        vendorName: vendorName,
        deliveryFee: deliveryFee,
        product: product,
      );
      return;
    }

    final cart = state.cart ??
        Cart(
          vendorId: vendorId,
          vendorName: vendorName,
          deliveryFee: deliveryFee,
        );

    final existingIndex =
        cart.items.indexWhere((item) => item.product.id == product.id);
    List<CartItem> updatedItems;

    if (existingIndex >= 0) {
      updatedItems = List.from(cart.items);
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] =
          existing.copyWith(quantity: existing.quantity + 1);
    } else {
      updatedItems = [...cart.items, CartItem(product: product)];
    }

    emit(CartState(cart: cart.copyWith(items: updatedItems)));
  }

  void _replaceCart({
    required String vendorId,
    required String vendorName,
    required double deliveryFee,
    required ProductModel product,
  }) {
    final cart = Cart(
      vendorId: vendorId,
      vendorName: vendorName,
      deliveryFee: deliveryFee,
      items: [CartItem(product: product)],
    );
    emit(CartState(cart: cart));
  }

  void updateQuantity(String productId, int quantity) {
    if (state.cart == null) return;

    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final updatedItems = state.cart!.items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    emit(CartState(cart: state.cart!.copyWith(items: updatedItems)));
  }

  void removeItem(String productId) {
    if (state.cart == null) return;

    final updatedItems =
        state.cart!.items.where((item) => item.product.id != productId).toList();

    if (updatedItems.isEmpty) {
      emit(const CartState());
    } else {
      emit(CartState(cart: state.cart!.copyWith(items: updatedItems)));
    }
  }

  void clearCart() {
    emit(const CartState());
  }

  int getProductQuantity(String productId) {
    if (state.cart == null) return 0;
    final item = state.cart!.items.where((i) => i.product.id == productId);
    return item.isEmpty ? 0 : item.first.quantity;
  }
}
