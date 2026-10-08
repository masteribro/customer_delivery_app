import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/product_model.dart';
import '../../bloc/cart/cart_cubit.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  ProductModel get product => widget.product as ProductModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.shadow, blurRadius: 8),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 18),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.background,
                child: product.imageUrl.isNotEmpty
                    ? Image.network(product.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder())
                    : _placeholder(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.hasDiscount)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${product.discountPercent}% OFF',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  Text(product.name, style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'NGN ${product.effectivePrice.toStringAsFixed(0)}',
                        style: AppTextStyles.price.copyWith(fontSize: 22),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 10),
                        Text(
                          'NGN ${product.price.toStringAsFixed(0)}',
                          style: AppTextStyles.priceStrikethrough
                              .copyWith(fontSize: 16),
                        ),
                      ],
                    ],
                  ),
                  if (product.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Description',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Text(product.description,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                  const SizedBox(height: 28),
                  // Quantity selector
                  Row(
                    children: [
                      Text('Quantity', style: AppTextStyles.labelMedium),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            _QtyButton(
                              icon: Icons.remove,
                              onTap: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                            ),
                            SizedBox(
                              width: 44,
                              child: Text(
                                '$_quantity',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.labelLarge,
                              ),
                            ),
                            _QtyButton(
                              icon: Icons.add,
                              onTap: () => setState(() => _quantity++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
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
            onPressed: () {
              final cartCubit = context.read<CartCubit>();
              for (var i = 0; i < _quantity; i++) {
                cartCubit.addToCart(
                  product: product,
                  vendorId: product.vendorId,
                  vendorName: '',
                  deliveryFee: 0,
                );
              }
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$_quantity x ${product.name} added to cart'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'Add to Cart - NGN ${(product.effectivePrice * _quantity).toStringAsFixed(0)}',
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(Icons.fastfood_outlined,
          size: 56, color: AppColors.textTertiary.withValues(alpha: 0.2)),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          size: 20,
          color: onTap != null ? AppColors.primary : AppColors.disabled,
        ),
      ),
    );
  }
}
