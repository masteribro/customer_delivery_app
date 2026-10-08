part of 'vendor_detail_cubit.dart';

abstract class VendorDetailState extends Equatable {
  const VendorDetailState();
  @override
  List<Object?> get props => [];
}

class VendorDetailInitial extends VendorDetailState {}

class VendorDetailLoading extends VendorDetailState {}

class VendorDetailLoaded extends VendorDetailState {
  final VendorModel vendor;
  final List<ProductModel> products;
  final Map<String, List<ProductModel>> menuCategories;

  const VendorDetailLoaded({
    required this.vendor,
    required this.products,
    required this.menuCategories,
  });

  @override
  List<Object?> get props => [vendor.id, products.length];
}

class VendorDetailError extends VendorDetailState {
  final String message;
  const VendorDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
