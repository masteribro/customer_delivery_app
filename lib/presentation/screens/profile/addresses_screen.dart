import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../bloc/auth/auth_cubit.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Delivery Addresses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final addresses = state is AuthAuthenticated
              ? state.user.addresses
              : <DeliveryAddress>[];

          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_off_outlined,
                      size: 56,
                      color: AppColors.textSecondary.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  Text('No saved addresses',
                      style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  Text('Add an address for faster checkout',
                      style: AppTextStyles.bodySmall),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final addr = addresses[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: addr.isDefault
                        ? AppColors.primary
                        : AppColors.border,
                    width: addr.isDefault ? 1.5 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: addr.isDefault
                            ? AppColors.primarySurface
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        addr.label.toLowerCase() == 'home'
                            ? Icons.home_outlined
                            : addr.label.toLowerCase() == 'work'
                                ? Icons.work_outline
                                : Icons.location_on_outlined,
                        size: 20,
                        color: addr.isDefault
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(addr.label,
                                  style: AppTextStyles.labelMedium),
                              if (addr.isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('Default',
                                      style: AppTextStyles.caption.copyWith(
                                          color: AppColors.primary,
                                          fontSize: 10)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(addr.address,
                              style: AppTextStyles.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final labelController = TextEditingController(text: 'Home');
    final addressController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Address', style: AppTextStyles.h3),
            const SizedBox(height: 20),
            TextField(
              controller: labelController,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Label (e.g. Home, Work)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              style: AppTextStyles.bodyMedium,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Enter your full address',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (addressController.text.trim().isEmpty) return;
                final user = context.read<AuthCubit>().userProfile;
                if (user == null) return;

                final newAddr = DeliveryAddress(
                  id: const Uuid().v4(),
                  label: labelController.text.trim(),
                  address: addressController.text.trim(),
                  isDefault: user.addresses.isEmpty,
                );

                final updated = [...user.addresses, newAddr];
                await AuthRepository().updateUserProfile(user.uid, {
                  'addresses': updated.map((a) => a.toMap()).toList(),
                });
                if (context.mounted) {
                  context.read<AuthCubit>().refreshProfile();
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save Address'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
