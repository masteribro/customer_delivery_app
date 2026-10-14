import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final notifications = await _notificationService.getNotifications();
    setState(() {
      _notifications = notifications;
      _loading = false;
    });
  }

  Future<void> _markAllRead() async {
    await _notificationService.markAllAsRead();
    await _loadNotifications();
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Notifications'),
        content: const Text('Are you sure you want to clear all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _notificationService.clearAll();
      await _loadNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notifications', style: AppTextStyles.h3),
        actions: [
          if (_notifications.isNotEmpty) ...[
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
              onSelected: (value) {
                if (value == 'read') _markAllRead();
                if (value == 'clear') _clearAll();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'read',
                  child: Text('Mark all as read'),
                ),
                const PopupMenuItem(
                  value: 'clear',
                  child: Text('Clear all'),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _notifications.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 72, endIndent: 20),
                    itemBuilder: (context, index) {
                      return _buildNotificationTile(_notifications[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text('No notifications yet', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            'When you receive notifications,\nthey will appear here',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    final isRead = notification['read'] == true;
    final title = notification['title'] ?? 'Notification';
    final body = notification['body'] ?? '';
    final timestamp = DateTime.tryParse(notification['timestamp'] ?? '');
    final timeStr = timestamp != null ? _formatTime(timestamp) : '';

    final icon = _getNotificationIcon(title);

    return InkWell(
      onTap: () async {
        final id = notification['id']?.toString();
        if (id != null && !isRead) {
          await _notificationService.markAsRead(id);
          await _loadNotifications();
        }
      },
      child: Container(
        color: isRead ? Colors.transparent : AppColors.primarySurface.withAlpha(80),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: icon.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon.iconData, size: 22, color: icon.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    timeStr,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dateTime);
  }

  _NotifIcon _getNotificationIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('order') && lower.contains('confirm')) {
      return _NotifIcon(Icons.check_circle_outline, AppColors.success, AppColors.successLight);
    }
    if (lower.contains('deliver')) {
      return _NotifIcon(Icons.local_shipping_outlined, AppColors.primary, AppColors.primarySurface);
    }
    if (lower.contains('cancel')) {
      return _NotifIcon(Icons.cancel_outlined, AppColors.error, AppColors.errorLight);
    }
    if (lower.contains('prepar')) {
      return _NotifIcon(Icons.restaurant_outlined, AppColors.warning, AppColors.warningLight);
    }
    if (lower.contains('ready')) {
      return _NotifIcon(Icons.takeout_dining_outlined, AppColors.success, AppColors.successLight);
    }
    if (lower.contains('promo') || lower.contains('offer') || lower.contains('discount')) {
      return _NotifIcon(Icons.local_offer_outlined, AppColors.secondary, AppColors.secondarySurface);
    }
    return _NotifIcon(Icons.notifications_outlined, AppColors.primary, AppColors.primarySurface);
  }
}

class _NotifIcon {
  final IconData iconData;
  final Color color;
  final Color bgColor;
  const _NotifIcon(this.iconData, this.color, this.bgColor);
}
