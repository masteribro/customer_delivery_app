import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String vendorId;
  final String name;
  final String description;
  final String imageUrl;
  final String menuCategory;
  final double price;
  final double? discountPrice;
  final bool isAvailable;
  final List<String> tags;

  const ProductModel({
    required this.id,
    required this.vendorId,
    required this.name,
    this.description = '',
    this.imageUrl = '',
    this.menuCategory = 'Main',
    required this.price,
    this.discountPrice,
    this.isAvailable = true,
    this.tags = const [],
  });

  double get effectivePrice => discountPrice ?? price;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  int get discountPercent =>
      hasDiscount ? ((1 - discountPrice! / price) * 100).round() : 0;

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      vendorId: data['vendorId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      menuCategory: data['menuCategory'] ?? 'Main',
      price: (data['price'] ?? 0).toDouble(),
      discountPrice: data['discountPrice'] != null
          ? (data['discountPrice']).toDouble()
          : null,
      isAvailable: data['isAvailable'] ?? true,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vendorId': vendorId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'menuCategory': menuCategory,
      'price': price,
      'discountPrice': discountPrice,
      'isAvailable': isAvailable,
      'tags': tags,
    };
  }
}
