import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/order_model.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/orders/orders_cubit.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    final user = context.read<AuthCubit>().userProfile;
    if (user != null) {
      context.read<OrdersCubit>().loadOrders(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Orders')),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is OrdersError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(state.message,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                        )),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _loadOrders,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is OrdersLoaded) {
            if (state.orders.isEmpty) return _buildEmpty();
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => _loadOrders(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _OrderCard(
                    order: state.orders[index],
                    onTap: () =>
                        context.push('/order/${state.orders[index].id}'),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64, color: AppColors.disabled),
          const SizedBox(height: 16),
          Text('No orders yet', style: AppTextStyles.h3),
          const SizedBox(height: 6),
          Text('Your orders will appear here',
              style: AppTextStyles.bodySmall),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => context.go('/home'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(180, 46),
            ),
            child: const Text('Start Ordering'),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  Color get _statusColor {
    switch (order.status) {
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'preparing':
      case 'picked_up':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  Color get _statusBgColor {
    switch (order.status) {
      case 'delivered':
        return AppColors.successLight;
      case 'cancelled':
        return AppColors.errorLight;
      case 'preparing':
      case 'picked_up':
        return AppColors.warningLight;
      default:
        return AppColors.infoLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.vendorName,
                          style: AppTextStyles.labelMedium),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('MMM d, yyyy · h:mm a')
                            .format(order.createdAt),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.statusLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: _statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              '${order.items.length} item${order.items.length > 1 ? 's' : ''} · ${order.items.map((i) => i.name).join(', ')}',
              style: AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
                Text('NGN ${order.total.toStringAsFixed(0)}',
                    style: AppTextStyles.labelMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
