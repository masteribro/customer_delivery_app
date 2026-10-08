import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/vendor_model.dart';
import '../../../data/repositories/vendor_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final VendorRepository _vendorRepo;

  HomeCubit(this._vendorRepo) : super(HomeInitial());

  Future<void> loadHome() async {
    emit(HomeLoading());
    try {
      final categories = await _vendorRepo.getCategories();
      final featured = await _vendorRepo.getFeaturedVendors();
      final all = await _vendorRepo.getVendors();
      emit(HomeLoaded(
        categories: categories,
        featuredVendors: featured,
        allVendors: all,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> filterByCategory(String? category) async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    try {
      final vendors = await _vendorRepo.getVendors(category: category);
      emit(currentState.copyWith(
        allVendors: vendors,
        selectedCategory: category,
      ));
    } catch (e) {
      // Keep current state on filter error
    }
  }
}
