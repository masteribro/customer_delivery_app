import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String phone;
  final String name;
  final String email;
  final String? photoUrl;
  final String accountType;
  final double walletBalance;
  final List<DeliveryAddress> addresses;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.phone,
    this.name = '',
    this.email = '',
    this.photoUrl,
    this.accountType = 'customer',
    this.walletBalance = 0,
    this.addresses = const [],
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      phone: data['phone'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      accountType: data['accountType'] ?? 'customer',
      walletBalance: (data['walletBalance'] ?? 0).toDouble(),
      addresses: (data['addresses'] as List<dynamic>?)
              ?.map((a) => DeliveryAddress.fromMap(a as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'accountType': accountType,
      'walletBalance': walletBalance,
      'addresses': addresses.map((a) => a.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    double? walletBalance,
    List<DeliveryAddress>? addresses,
  }) {
    return UserModel(
      uid: uid,
      phone: phone,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      accountType: accountType,
      walletBalance: walletBalance ?? this.walletBalance,
      addresses: addresses ?? this.addresses,
      createdAt: createdAt,
    );
  }
}

class DeliveryAddress {
  final String id;
  final String label;
  final String address;
  final String? apartment;
  final String? instructions;
  final bool isDefault;

  const DeliveryAddress({
    required this.id,
    required this.label,
    required this.address,
    this.apartment,
    this.instructions,
    this.isDefault = false,
  });

  factory DeliveryAddress.fromMap(Map<String, dynamic> map) {
    return DeliveryAddress(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      address: map['address'] ?? '',
      apartment: map['apartment'],
      instructions: map['instructions'],
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'address': address,
      'apartment': apartment,
      'instructions': instructions,
      'isDefault': isDefault,
    };
  }
}
