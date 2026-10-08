import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrderRepository _orderRepo;
  StreamSubscription? _activeOrdersSub;

  OrdersCubit(this._orderRepo) : super(OrdersInitial());

  Future<void> loadOrders(String userId) async {
    emit(OrdersLoading());
    try {
      final orders = await _orderRepo.getOrders(userId);
      emit(OrdersLoaded(orders: orders));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  void watchActiveOrders(String userId) {
    _activeOrdersSub?.cancel();
    _activeOrdersSub = _orderRepo.getActiveOrders(userId).listen(
      (orders) {
        final currentState = state;
        if (currentState is OrdersLoaded) {
          emit(currentState.copyWith(activeOrders: orders));
        }
      },
    );
  }

  Future<String> placeOrder(OrderModel order) async {
    final orderId = await _orderRepo.createOrder(order);
    // Refresh orders list
    await loadOrders(order.userId);
    return orderId;
  }

  Future<void> cancelOrder(String orderId, String userId) async {
    await _orderRepo.cancelOrder(orderId);
    await loadOrders(userId);
  }

  @override
  Future<void> close() {
    _activeOrdersSub?.cancel();
    return super.close();
  }
}
