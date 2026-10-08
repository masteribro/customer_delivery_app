import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/vendor_model.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/home/home_cubit.dart';
import '../../bloc/cart/cart_cubit.dart';
import '../../widgets/vendor_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/shimmer_loading.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => context.read<HomeCubit>().loadHome(),
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(child: _buildHeader()),
              // Search Bar
              SliverToBoxAdapter(child: _buildSearchBar()),
              // Cart Banner
              SliverToBoxAdapter(child: _buildCartBanner()),
              // Content
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const SliverToBoxAdapter(child: HomeShimmer());
                  }
                  if (state is HomeError) {
                    return SliverFillRemaining(
                      child: _buildError(state.message),
                    );
                  }
                  if (state is HomeLoaded) {
                    return _buildContent(state);
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deliver to',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final name = state is AuthAuthenticated
                        ? state.user.name
                        : 'there';
                    return Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Hi, $name',
                          style: AppTextStyles.labelLarge,
                        ),
                        const Icon(Icons.keyboard_arrow_down,
                            size: 20, color: AppColors.textSecondary),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.notifications_outlined,
                  size: 22, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: GestureDetector(
        onTap: () => context.go('/search'),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 22, color: AppColors.textTertiary),
              const SizedBox(width: 12),
              Text(
                'Search restaurants, food...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartBanner() {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (!state.hasItems) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () => context.push('/cart'),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${state.itemCount}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'View Cart',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
                Text(
                  'NGN ${state.total.toStringAsFixed(0)}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.white),
              ],
            ),
          ),
        );
      },
    );
  }

  SliverList _buildContent(HomeLoaded state) {
    return SliverList(
      delegate: SliverChildListDelegate([
        // Categories
        if (state.categories.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildSectionTitle('Categories'),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: state.categories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return CategoryChip(
                    label: 'All',
                    isSelected: state.selectedCategory == null,
                    onTap: () =>
                        context.read<HomeCubit>().filterByCategory(null),
                  );
                }
                final cat = state.categories[index - 1];
                return CategoryChip(
                  label: cat.name,
                  isSelected: state.selectedCategory == cat.id,
                  onTap: () =>
                      context.read<HomeCubit>().filterByCategory(cat.id),
                );
              },
            ),
          ),
        ],

        // Featured Vendors
        if (state.featuredVendors.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionTitle('Featured'),
          const SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: state.featuredVendors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return FeaturedVendorCard(
                  vendor: state.featuredVendors[index],
                  onTap: () => context
                      .push('/vendor/${state.featuredVendors[index].id}'),
                );
              },
            ),
          ),
        ],

        // All Vendors
        const SizedBox(height: 24),
        _buildSectionTitle(
          state.selectedCategory != null
              ? 'Results'
              : 'All Restaurants',
        ),
        const SizedBox(height: 12),
        if (state.allVendors.isEmpty)
          _buildEmpty()
        else
          ...state.allVendors.map(
            (vendor) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: VendorCard(
                vendor: vendor,
                onTap: () => context.push('/vendor/${vendor.id}'),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(title, style: AppTextStyles.h3),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.storefront_outlined,
              size: 56, color: AppColors.textTertiary.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            'No restaurants found',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text('Something went wrong', style: AppTextStyles.labelLarge),
          const SizedBox(height: 4),
          Text(message,
              style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => context.read<HomeCubit>().loadHome(),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(140, 44),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class FeaturedVendorCard extends StatelessWidget {
  final VendorModel vendor;
  final VoidCallback onTap;

  const FeaturedVendorCard({
    super.key,
    required this.vendor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: Container(
                height: 130,
                width: double.infinity,
                color: AppColors.primarySurface,
                child: vendor.imageUrl.isNotEmpty
                    ? Image.network(vendor.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder())
                    : _placeholder(),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor.name,
                    style: AppTextStyles.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 15, color: AppColors.starFilled),
                      const SizedBox(width: 3),
                      Text(
                        vendor.rating.toStringAsFixed(1),
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('(${vendor.reviewCount})',
                          style: AppTextStyles.caption),
                      const Spacer(),
                      Icon(Icons.access_time,
                          size: 13, color: AppColors.textTertiary),
                      const SizedBox(width: 3),
                      Text('${vendor.prepTimeMinutes} min',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(Icons.restaurant_rounded,
          size: 36, color: AppColors.primary.withValues(alpha: 0.3)),
    );
  }
}
