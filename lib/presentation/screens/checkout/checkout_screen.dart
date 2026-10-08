import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/order_model.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/cart/cart_cubit.dart';
import '../../bloc/orders/orders_cubit.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isPlacing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().userProfile;
    if (user != null && user.addresses.isNotEmpty) {
      final defaultAddr =
          user.addresses.where((a) => a.isDefault).firstOrNull ??
              user.addresses.first;
      _addressController.text = defaultAddr.address;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a delivery address'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isPlacing = true);

    try {
      final cart = context.read<CartCubit>().state.cart!;
      final user = context.read<AuthCubit>().userProfile!;

      final order = OrderModel(
        id: '',
        userId: user.uid,
        vendorId: cart.vendorId,
        vendorName: cart.vendorName,
        items: cart.items
            .map((item) => OrderItem(
                  productId: item.product.id,
                  name: item.product.name,
                  imageUrl: item.product.imageUrl,
                  price: item.product.effectivePrice,
                  quantity: item.quantity,
                ))
            .toList(),
        subtotal: cart.subtotal,
        deliveryFee: cart.deliveryFee,
        total: cart.total,
        deliveryAddress: _addressController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      await context.read<OrdersCubit>().placeOrder(order);
      context.read<CartCubit>().clearCart();

      if (!mounted) return;

      // Show success bottom sheet
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 36, color: AppColors.success),
              ),
              const SizedBox(height: 20),
              const Text('Order Placed!', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text(
                'Your order has been placed successfully.\nWe\'ll notify you when it\'s on its way.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/orders');
                },
                child: const Text('Track Order'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/home');
                },
                child: const Text('Back to Home'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPlacing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (!state.hasItems) {
            return const Center(child: Text('Cart is empty'));
          }

          final cart = state.cart!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Delivery Address
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('Delivery Address',
                              style: AppTextStyles.labelMedium),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _addressController,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Enter your delivery address',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Order items
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Summary', style: AppTextStyles.labelMedium),
                      const SizedBox(height: 12),
                      ...cart.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: AppColors.primary),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${item.quantity}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(item.product.name,
                                      style: AppTextStyles.bodyMedium),
                                ),
                                Text(
                                  'NGN ${item.totalPrice.toStringAsFixed(0)}',
                                  style: AppTextStyles.labelMedium,
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Notes
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Delivery Notes (Optional)',
                          style: AppTextStyles.labelMedium),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesController,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Any special instructions...',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Pricing
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _PriceRow(
                          label: 'Subtotal',
                          value: 'NGN ${cart.subtotal.toStringAsFixed(0)}'),
                      const SizedBox(height: 8),
                      _PriceRow(
                        label: 'Delivery Fee',
                        value: cart.deliveryFee > 0
                            ? 'NGN ${cart.deliveryFee.toStringAsFixed(0)}'
                            : 'Free',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                      _PriceRow(
                        label: 'Total',
                        value: 'NGN ${cart.total.toStringAsFixed(0)}',
                        isBold: true,
                        isLarge: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
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
            onPressed: _isPlacing ? null : _placeOrder,
            child: _isPlacing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.white,
                    ),
                  )
                : const Text('Place Order'),
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final bool isLarge;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? AppTextStyles.labelLarge
              : AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: isLarge
              ? AppTextStyles.price.copyWith(fontSize: 18)
              : isBold
                  ? AppTextStyles.labelLarge
                  : AppTextStyles.labelMedium,
        ),
      ],
    );
  }
}
