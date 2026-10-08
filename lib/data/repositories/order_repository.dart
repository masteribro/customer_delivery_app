import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createOrder(OrderModel order) async {
    _log('CREATE order → vendor: ${order.vendorName}, total: ${order.total}');
    final doc = await _firestore.collection('orders').add(order.toMap());
    _log('CREATE order → SUCCESS id: ${doc.id}');
    return doc.id;
  }

  Future<List<OrderModel>> getOrders(String userId) async {
    _log('GET orders (userId=$userId)');
    final snapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    _log('GET orders → ${snapshot.docs.length} results');
    return snapshot.docs
        .map((doc) => OrderModel.fromFirestore(doc))
        .toList();
  }

  Stream<List<OrderModel>> getActiveOrders(String userId) {
    _log('WATCH active orders (userId=$userId)');
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('status', whereNotIn: ['delivered', 'cancelled'])
        .orderBy('status')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          _log('WATCH active orders → ${snapshot.docs.length} results');
          return snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
        });
  }

  Stream<OrderModel?> watchOrder(String orderId) {
    _log('WATCH order/$orderId');
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) {
          _log('WATCH order/$orderId → exists: ${doc.exists}, status: ${doc.data()?['status']}');
          return doc.exists ? OrderModel.fromFirestore(doc) : null;
        });
  }

  Future<void> cancelOrder(String orderId) async {
    _log('UPDATE order/$orderId → status: cancelled');
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'cancelled',
    });
    _log('UPDATE order/$orderId → SUCCESS');
  }

  void _log(String message) {
    dev.log('[FIRESTORE] $message', name: 'Kali');
  }
}
