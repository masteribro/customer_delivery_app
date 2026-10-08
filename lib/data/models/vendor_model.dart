import 'package:cloud_firestore/cloud_firestore.dart';

class VendorModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String logoUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final int prepTimeMinutes;
  final double deliveryFee;
  final double minOrder;
  final bool isOpen;
  final String address;
  final List<String> tags;

  const VendorModel({
    required this.id,
    required this.name,
    this.description = '',
    this.imageUrl = '',
    this.logoUrl = '',
    required this.category,
    this.rating = 0,
    this.reviewCount = 0,
    this.prepTimeMinutes = 30,
    this.deliveryFee = 0,
    this.minOrder = 0,
    this.isOpen = true,
    this.address = '',
    this.tags = const [],
  });

  factory VendorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VendorModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      category: data['category'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      prepTimeMinutes: data['prepTimeMinutes'] ?? 30,
      deliveryFee: (data['deliveryFee'] ?? 0).toDouble(),
      minOrder: (data['minOrder'] ?? 0).toDouble(),
      isOpen: data['isOpen'] ?? true,
      address: data['address'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'logoUrl': logoUrl,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'prepTimeMinutes': prepTimeMinutes,
      'deliveryFee': deliveryFee,
      'minOrder': minOrder,
      'isOpen': isOpen,
      'address': address,
      'tags': tags,
    };
  }
}

class VendorCategory {
  final String id;
  final String name;
  final String icon;
  final int sortOrder;

  const VendorCategory({
    required this.id,
    required this.name,
    this.icon = '',
    this.sortOrder = 0,
  });

  factory VendorCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VendorCategory(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      sortOrder: data['sortOrder'] ?? 0,
    );
  }
}
