import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../bloc/cart/cart_cubit.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Your Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (!state.hasItems) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => context.read<CartCubit>().clearCart(),
                child: Text('Clear',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.error)),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (!state.hasItems) return _buildEmptyCart(context);

          final cart = state.cart!;
          return Column(
            children: [
              // Vendor info
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.storefront,
                          size: 20, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(cart.vendorName.isNotEmpty
                          ? cart.vendorName
                          : 'Restaurant',
                          style: AppTextStyles.labelLarge),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Items
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Container(
                      color: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          // Product image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 56,
                              height: 56,
                              color: AppColors.background,
                              child: item.product.imageUrl.isNotEmpty
                                  ? Image.network(item.product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _imgPlaceholder())
                                  : _imgPlaceholder(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product.name,
                                    style: AppTextStyles.labelMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(
                                  'NGN ${item.totalPrice.toStringAsFixed(0)}',
                                  style: AppTextStyles.priceSmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Quantity controls
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () => context
                                      .read<CartCubit>()
                                      .updateQuantity(item.product.id,
                                          item.quantity - 1),
                                  child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(Icons.remove,
                                        size: 16, color: AppColors.primary),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text('${item.quantity}',
                                      style: AppTextStyles.labelMedium),
                                ),
                                GestureDetector(
                                  onTap: () => context
                                      .read<CartCubit>()
                                      .updateQuantity(item.product.id,
                                          item.quantity + 1),
                                  child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(Icons.add,
                                        size: 16, color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Summary
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  child: Column(
                    children: [
                      _SummaryRow(
                          label: 'Subtotal',
                          value: 'NGN ${cart.subtotal.toStringAsFixed(0)}'),
                      const SizedBox(height: 8),
                      _SummaryRow(
                          label: 'Delivery Fee',
                          value: cart.deliveryFee > 0
                              ? 'NGN ${cart.deliveryFee.toStringAsFixed(0)}'
                              : 'Free',
                          valueColor: cart.deliveryFee == 0
                              ? AppColors.success
                              : null),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                      _SummaryRow(
                        label: 'Total',
                        value: 'NGN ${cart.total.toStringAsFixed(0)}',
                        isBold: true,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.push('/checkout'),
                        child: const Text('Proceed to Checkout'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _imgPlaceholder() {
    return Center(
      child: Icon(Icons.fastfood_outlined,
          size: 20, color: AppColors.textTertiary.withValues(alpha: 0.3)),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 64, color: AppColors.textTertiary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('Your cart is empty', style: AppTextStyles.h3),
          const SizedBox(height: 6),
          Text(
            'Add items from a restaurant to get started',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => context.go('/home'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(180, 46),
            ),
            child: const Text('Browse Restaurants'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold ? AppTextStyles.labelLarge : AppTextStyles.bodyMedium,
        ),
        Text(
          value,
          style: (isBold ? AppTextStyles.labelLarge : AppTextStyles.labelMedium)
              .copyWith(color: valueColor),
        ),
      ],
    );
  }
}
