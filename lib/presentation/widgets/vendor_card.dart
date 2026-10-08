import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/vendor_model.dart';

class VendorCard extends StatelessWidget {
  final VendorModel vendor;
  final VoidCallback onTap;

  const VendorCard({super.key, required this.vendor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(14),
              ),
              child: Container(
                width: 100,
                height: 100,
                color: AppColors.primarySurface,
                child: vendor.imageUrl.isNotEmpty
                    ? Image.network(vendor.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder())
                    : _placeholder(),
              ),
            ),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vendor.name,
                            style: AppTextStyles.labelMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!vendor.isOpen)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Closed',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.error,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vendor.category,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: AppColors.starFilled),
                        const SizedBox(width: 3),
                        Text(
                          vendor.rating.toStringAsFixed(1),
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time_rounded,
                            size: 13, color: AppColors.textTertiary),
                        const SizedBox(width: 3),
                        Text('${vendor.prepTimeMinutes} min',
                            style: AppTextStyles.caption),
                        const SizedBox(width: 12),
                        Icon(Icons.delivery_dining_outlined,
                            size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 3),
                        Text(
                          vendor.deliveryFee > 0
                              ? 'NGN ${vendor.deliveryFee.toStringAsFixed(0)}'
                              : 'Free',
                          style: AppTextStyles.caption.copyWith(
                            color: vendor.deliveryFee == 0
                                ? AppColors.success
                                : null,
                            fontWeight: vendor.deliveryFee == 0
                                ? FontWeight.w600
                                : null,
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
      ),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(Icons.restaurant_rounded,
          size: 28, color: AppColors.primary.withValues(alpha: 0.3)),
    );
  }
}
