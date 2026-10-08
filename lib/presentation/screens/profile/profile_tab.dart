import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../bloc/auth/auth_cubit.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Account')),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user =
              state is AuthAuthenticated ? state.user : null;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile header
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primarySurface,
                        backgroundImage: user?.photoUrl != null
                            ? NetworkImage(user!.photoUrl!)
                            : null,
                        child: user?.photoUrl == null
                            ? Text(
                                (user?.name ?? 'U')
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: AppTextStyles.h2.copyWith(
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.name ?? 'User',
                                style: AppTextStyles.labelLarge),
                            const SizedBox(height: 2),
                            Text(user?.phone ?? '',
                                style: AppTextStyles.bodySmall),
                            if (user?.email.isNotEmpty == true)
                              Text(user!.email,
                                  style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push('/edit-profile'),
                        icon: const Icon(Icons.edit_outlined,
                            size: 20, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Menu Items
                Container(
                  color: AppColors.white,
                  child: Column(
                    children: [
                      _MenuItem(
                        icon: Icons.location_on_outlined,
                        label: 'Delivery Addresses',
                        onTap: () => context.push('/addresses'),
                      ),
                      const Divider(indent: 56),
                      _MenuItem(
                        icon: Icons.receipt_long_outlined,
                        label: 'Order History',
                        onTap: () => context.go('/orders'),
                      ),
                      const Divider(indent: 56),
                      _MenuItem(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Wallet',
                        onTap: () => context.go('/wallet'),
                      ),
                      const Divider(indent: 56),
                      _MenuItem(
                        icon: Icons.favorite_border_rounded,
                        label: 'Favorites',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  color: AppColors.white,
                  child: Column(
                    children: [
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        onTap: () {},
                      ),
                      const Divider(indent: 56),
                      _MenuItem(
                        icon: Icons.info_outline_rounded,
                        label: 'About',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  color: AppColors.white,
                  child: _MenuItem(
                    icon: Icons.logout_rounded,
                    label: 'Sign Out',
                    color: AppColors.error,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text(
                              'Are you sure you want to sign out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                context.read<AuthCubit>().signOut();
                                context.go('/login');
                              },
                              child: Text('Sign Out',
                                  style: TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),

                Text('Kali v1.0.0',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.disabled)),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 22, color: color ?? AppColors.textSecondary),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: color ?? AppColors.textPrimary,
        ),
      ),
      trailing: Icon(Icons.chevron_right,
          size: 20, color: color ?? AppColors.textTertiary),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
