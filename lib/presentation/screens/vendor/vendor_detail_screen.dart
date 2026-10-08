import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/vendor_model.dart';
import '../../../data/repositories/vendor_repository.dart';
import '../../bloc/vendor/vendor_detail_cubit.dart';
import '../../bloc/cart/cart_cubit.dart';

class VendorDetailScreen extends StatelessWidget {
  final String vendorId;

  const VendorDetailScreen({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VendorDetailCubit(VendorRepository())..loadVendor(vendorId),
      child: const _VendorDetailView(),
    );
  }
}

class _VendorDetailView extends StatelessWidget {
  const _VendorDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorDetailCubit, VendorDetailState>(
      builder: (context, state) {
        if (state is VendorDetailLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (state is VendorDetailError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(state.message)),
          );
        }
        if (state is VendorDetailLoaded) {
          return _VendorDetailBody(state: state);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _VendorDetailBody extends StatelessWidget {
  final VendorDetailLoaded state;

  const _VendorDetailBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final vendor = state.vendor;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.white,
            leading: _BackButton(),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primarySurface,
                child: vendor.imageUrl.isNotEmpty
                    ? Image.network(vendor.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePlaceholder())
                    : _imagePlaceholder(),
              ),
            ),
          ),

          // Vendor Info
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(vendor.name, style: AppTextStyles.h2),
                      ),
                      if (!vendor.isOpen)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Closed',
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.error)),
                        ),
                    ],
                  ),
                  if (vendor.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(vendor.description,
                        style: AppTextStyles.bodySmall, maxLines: 2),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.star_rounded,
                        iconColor: AppColors.starFilled,
                        text: '${vendor.rating.toStringAsFixed(1)} (${vendor.reviewCount})',
                      ),
                      const SizedBox(width: 16),
                      _InfoChip(
                        icon: Icons.access_time_rounded,
                        text: '${vendor.prepTimeMinutes} min',
                      ),
                      const SizedBox(width: 16),
                      _InfoChip(
                        icon: Icons.delivery_dining_outlined,
                        text: vendor.deliveryFee > 0
                            ? 'NGN ${vendor.deliveryFee.toStringAsFixed(0)}'
                            : 'Free delivery',
                      ),
                    ],
                  ),
                  if (vendor.minOrder > 0) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Min. order: NGN ${vendor.minOrder.toStringAsFixed(0)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Menu Categories
          if (state.menuCategories.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text('No menu items yet',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textTertiary)),
              ),
            )
          else
            ...state.menuCategories.entries.expand((entry) => [
                  SliverToBoxAdapter(
                    child: Container(
                      color: AppColors.white,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text(entry.key, style: AppTextStyles.h3),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = entry.value[index];
                        return _ProductTile(
                          product: product,
                          vendor: vendor,
                        );
                      },
                      childCount: entry.value.length,
                    ),
                  ),
                ]),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // Cart Bottom Bar
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        builder: (context, cartState) {
          if (!cartState.hasItems) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () => context.push('/cart'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('View Cart (${cartState.itemCount})'),
                    const Spacer(),
                    Text('NGN ${cartState.total.toStringAsFixed(0)}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Center(
      child: Icon(Icons.restaurant_rounded,
          size: 48, color: AppColors.primary.withValues(alpha: 0.2)),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String text;

  const _InfoChip({
    required this.icon,
    this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: iconColor ?? AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _ProductTile extends StatelessWidget {
  final ProductModel product;
  final VendorModel vendor;

  const _ProductTile({required this.product, required this.vendor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/product', extra: product),
      child: Container(
        color: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 80,
                height: 80,
                color: AppColors.background,
                child: product.imageUrl.isNotEmpty
                    ? Image.network(product.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder())
                    : _placeholder(),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: AppTextStyles.labelMedium, maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (product.description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(product.description,
                        style: AppTextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'NGN ${product.effectivePrice.toStringAsFixed(0)}',
                        style: AppTextStyles.priceSmall,
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          'NGN ${product.price.toStringAsFixed(0)}',
                          style: AppTextStyles.priceStrikethrough,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Add button
            _AddButton(product: product, vendor: vendor),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(Icons.fastfood_outlined,
          size: 24, color: AppColors.textTertiary.withValues(alpha: 0.3)),
    );
  }
}

class _AddButton extends StatelessWidget {
  final ProductModel product;
  final VendorModel vendor;

  const _AddButton({required this.product, required this.vendor});

  @override
  Widget build(BuildContext context) {
    final cartCubit = context.watch<CartCubit>();
    final qty = cartCubit.getProductQuantity(product.id);

    if (qty == 0) {
      return GestureDetector(
        onTap: () {
          cartCubit.addToCart(
            product: product,
            vendorId: vendor.id,
            vendorName: vendor.name,
            deliveryFee: vendor.deliveryFee,
          );
        },
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.add, size: 20, color: AppColors.white),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => cartCubit.updateQuantity(product.id, qty - 1),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.remove, size: 18, color: AppColors.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('$qty',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.primary)),
          ),
          GestureDetector(
            onTap: () {
              cartCubit.addToCart(
                product: product,
                vendorId: vendor.id,
                vendorName: vendor.name,
                deliveryFee: vendor.deliveryFee,
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.add, size: 18, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
