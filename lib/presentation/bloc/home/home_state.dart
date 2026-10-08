part of 'home_cubit.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<VendorCategory> categories;
  final List<VendorModel> featuredVendors;
  final List<VendorModel> allVendors;
  final String? selectedCategory;

  const HomeLoaded({
    this.categories = const [],
    this.featuredVendors = const [],
    this.allVendors = const [],
    this.selectedCategory,
  });

  HomeLoaded copyWith({
    List<VendorCategory>? categories,
    List<VendorModel>? featuredVendors,
    List<VendorModel>? allVendors,
    String? selectedCategory,
  }) {
    return HomeLoaded(
      categories: categories ?? this.categories,
      featuredVendors: featuredVendors ?? this.featuredVendors,
      allVendors: allVendors ?? this.allVendors,
      selectedCategory: selectedCategory,
    );
  }

  @override
  List<Object?> get props =>
      [categories, featuredVendors, allVendors, selectedCategory];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object?> get props => [message];
}
