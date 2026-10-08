import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/vendor_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/vendor_repository.dart';

part 'vendor_detail_state.dart';

class VendorDetailCubit extends Cubit<VendorDetailState> {
  final VendorRepository _vendorRepo;

  VendorDetailCubit(this._vendorRepo) : super(VendorDetailInitial());

  Future<void> loadVendor(String vendorId) async {
    emit(VendorDetailLoading());
    try {
      final vendor = await _vendorRepo.getVendor(vendorId);
      if (vendor == null) {
        emit(const VendorDetailError('Vendor not found'));
        return;
      }
      final products = await _vendorRepo.getProducts(vendorId);

      // Group products by menu category
      final menuCategories = <String, List<ProductModel>>{};
      for (final product in products) {
        menuCategories
            .putIfAbsent(product.menuCategory, () => [])
            .add(product);
      }

      emit(VendorDetailLoaded(
        vendor: vendor,
        products: products,
        menuCategories: menuCategories,
      ));
    } catch (e) {
      emit(VendorDetailError(e.toString()));
    }
  }
}
