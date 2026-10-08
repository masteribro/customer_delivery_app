part of 'orders_cubit.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();
  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<OrderModel> orders;
  final List<OrderModel> activeOrders;

  const OrdersLoaded({
    this.orders = const [],
    this.activeOrders = const [],
  });

  OrdersLoaded copyWith({
    List<OrderModel>? orders,
    List<OrderModel>? activeOrders,
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      activeOrders: activeOrders ?? this.activeOrders,
    );
  }

  @override
  List<Object?> get props => [orders.length, activeOrders.length];
}

class OrdersError extends OrdersState {
  final String message;
  const OrdersError(this.message);
  @override
  List<Object?> get props => [message];
}
