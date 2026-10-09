import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: StreamBuilder<OrderModel?>(
        stream: OrderRepository().watchOrder(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final order = snapshot.data;
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }
          return _OrderDetailBody(order: order);
        },
      ),
    );
  }
}

class _OrderDetailBody extends StatelessWidget {
  final OrderModel order;

  const _OrderDetailBody({required this.order});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Status
          Container(
            color: AppColors.white,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _StatusIcon(status: order.status),
                const SizedBox(height: 14),
                Text(order.statusLabel, style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text(
                  _statusDescription(order.status),
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Order Timeline
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order Timeline', style: AppTextStyles.labelMedium),
                const SizedBox(height: 16),
                _TimelineStep(
                  label: 'Order Placed',
                  time: DateFormat('h:mm a').format(order.createdAt),
                  isCompleted: true,
                  isFirst: true,
                ),
                _TimelineStep(
                  label: 'Confirmed',
                  isCompleted: _statusIndex(order.status) >= 1,
                ),
                _TimelineStep(
                  label: 'Preparing',
                  isCompleted: _statusIndex(order.status) >= 2,
                ),
                _TimelineStep(
                  label: 'On the Way',
                  isCompleted: _statusIndex(order.status) >= 4,
                ),
                _TimelineStep(
                  label: 'Delivered',
                  isCompleted: _statusIndex(order.status) >= 5,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Restaurant
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.storefront,
                      size: 22, color: AppColors.primary),
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
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Items
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Items', style: AppTextStyles.labelMedium),
                const SizedBox(height: 12),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text('${item.quantity}',
                                  style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(item.name,
                                style: AppTextStyles.bodyMedium),
                          ),
                          Text(
                            'NGN ${item.total.toStringAsFixed(0)}',
                            style: AppTextStyles.labelMedium,
                          ),
                        ],
                      ),
                    )),
                const Divider(height: 24),
                _Row('Subtotal', 'NGN ${order.subtotal.toStringAsFixed(0)}'),
                const SizedBox(height: 6),
                _Row('Delivery Fee',
                    'NGN ${order.deliveryFee.toStringAsFixed(0)}'),
                const Divider(height: 24),
                _Row('Total', 'NGN ${order.total.toStringAsFixed(0)}',
                    bold: true),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Delivery address
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Delivery Address',
                          style: AppTextStyles.labelSmall),
                      const SizedBox(height: 4),
                      Text(order.deliveryAddress,
                          style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  int _statusIndex(String status) {
    const statuses = [
      'pending',
      'confirmed',
      'preparing',
      'ready',
      'picked_up',
      'delivered'
    ];
    return statuses.indexOf(status);
  }

  String _statusDescription(String status) {
    switch (status) {
      case 'pending':
        return 'Waiting for restaurant to confirm';
      case 'confirmed':
        return 'Restaurant has confirmed your order';
      case 'preparing':
        return 'Your food is being prepared';
      case 'ready':
        return 'Your order is ready for pickup';
      case 'picked_up':
        return 'Rider is on the way to you';
      case 'delivered':
        return 'Your order has been delivered';
      case 'cancelled':
        return 'This order was cancelled';
      default:
        return '';
    }
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _Row(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: bold
                ? AppTextStyles.labelMedium
                : AppTextStyles.bodySmall),
        Text(value,
            style: bold
                ? AppTextStyles.labelLarge
                : AppTextStyles.labelMedium),
      ],
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final String status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    Color bgColor;

    switch (status) {
      case 'delivered':
        icon = Icons.check_circle_outline;
        color = AppColors.success;
        bgColor = AppColors.successLight;
        break;
      case 'cancelled':
        icon = Icons.cancel_outlined;
        color = AppColors.error;
        bgColor = AppColors.errorLight;
        break;
      case 'picked_up':
        icon = Icons.delivery_dining;
        color = AppColors.warning;
        bgColor = AppColors.warningLight;
        break;
      default:
        icon = Icons.access_time_rounded;
        color = AppColors.info;
        bgColor = AppColors.infoLight;
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 32, color: color),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String label;
  final String? time;
  final bool isCompleted;
  final bool isFirst;
  final bool isLast;

  const _TimelineStep({
    required this.label,
    this.time,
    this.isCompleted = false,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppColors.primary : AppColors.border,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 32,
                  color: isCompleted ? AppColors.primary : AppColors.border,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isCompleted
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight:
                        isCompleted ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
                if (time != null) ...[
                  const Spacer(),
                  Text(time!, style: AppTextStyles.caption),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
