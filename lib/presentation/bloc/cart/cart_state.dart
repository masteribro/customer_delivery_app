part of 'cart_cubit.dart';

class CartState extends Equatable {
  final Cart? cart;

  const CartState({this.cart});

  bool get hasItems => cart != null && !cart!.isEmpty;
  int get itemCount => cart?.itemCount ?? 0;
  double get total => cart?.total ?? 0;

  @override
  List<Object?> get props => [cart?.vendorId, cart?.itemCount, cart?.total];
}
