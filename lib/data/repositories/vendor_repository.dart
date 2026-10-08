import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vendor_model.dart';
import '../models/product_model.dart';

class VendorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<VendorCategory>> getCategories() async {
    _log('GET categories (orderBy sortOrder)');
    final snapshot = await _firestore
        .collection('categories')
        .orderBy('sortOrder')
        .get();
    _log('GET categories → ${snapshot.docs.length} results');
    return snapshot.docs
        .map((doc) => VendorCategory.fromFirestore(doc))
        .toList();
  }

  Future<List<VendorModel>> getVendors({String? category}) async {
    _log('GET vendors${category != null ? ' (category=$category)' : ''}');
    Query query = _firestore.collection('vendors');
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    final snapshot = await query.get();
    _log('GET vendors → ${snapshot.docs.length} results');
    return snapshot.docs
        .map((doc) => VendorModel.fromFirestore(doc))
        .toList();
  }

  Future<List<VendorModel>> searchVendors(String query) async {
    _log('SEARCH vendors → "$query"');
    final snapshot = await _firestore.collection('vendors').get();
    final lowerQuery = query.toLowerCase();
    final results = snapshot.docs
        .map((doc) => VendorModel.fromFirestore(doc))
        .where((v) =>
            v.name.toLowerCase().contains(lowerQuery) ||
            v.category.toLowerCase().contains(lowerQuery) ||
            v.tags.any((t) => t.toLowerCase().contains(lowerQuery)))
        .toList();
    _log('SEARCH vendors → ${results.length} matches');
    return results;
  }

  Future<VendorModel?> getVendor(String id) async {
    _log('GET vendors/$id');
    final doc = await _firestore.collection('vendors').doc(id).get();
    _log('GET vendors/$id → exists: ${doc.exists}');
    if (doc.exists) {
      return VendorModel.fromFirestore(doc);
    }
    return null;
  }

  Future<List<ProductModel>> getProducts(String vendorId) async {
    _log('GET products (vendorId=$vendorId)');
    final snapshot = await _firestore
        .collection('products')
        .where('vendorId', isEqualTo: vendorId)
        .get();
    _log('GET products → ${snapshot.docs.length} results');
    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();
  }

  Future<List<VendorModel>> getFeaturedVendors() async {
    _log('GET vendors (featured, isOpen=true, limit=10)');
    final snapshot = await _firestore
        .collection('vendors')
        .where('isOpen', isEqualTo: true)
        .limit(10)
        .get();
    _log('GET vendors (featured) → ${snapshot.docs.length} results');
    return snapshot.docs
        .map((doc) => VendorModel.fromFirestore(doc))
        .toList();
  }

  void _log(String message) {
    dev.log('[FIRESTORE] $message', name: 'Kali');
  }
}
