import 'dart:convert';
import 'dart:developer' as dev;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Top-level handler for background messages (must be top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  dev.log('[FCM] Background message: ${message.messageId}', name: 'Kali');
  await NotificationService._saveNotification(message);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _notificationsKey = 'app_notifications';

  /// Android notification channel
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'kali_orders',
    'Order Updates',
    description: 'Notifications for order status updates',
    importance: Importance.high,
  );

  /// Initialize FCM and local notifications.
  Future<void> init() async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    _log('Permission status: ${settings.authorizationStatus}');

    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Init local notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Set background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // When app is opened via notification tap (from terminated/background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

    // Check if app was opened from a notification (terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpen(initialMessage);
    }

    // iOS foreground presentation
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Save FCM token
    await _saveFcmToken();

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((token) => _saveFcmTokenValue(token));
  }

  /// Get FCM token and save to Firestore user document.
  Future<void> _saveFcmToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      _log('FCM Token: ${token.substring(0, 20)}...');
      await _saveFcmTokenValue(token);
    }
  }

  Future<void> _saveFcmTokenValue(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      _log('FCM token saved to Firestore');
    }
  }

  /// Handle foreground messages — show local notification.
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    _log('Foreground message: ${message.notification?.title}');

    await _saveNotification(message);

    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleNotificationOpen(RemoteMessage message) {
    _log('Notification opened: ${message.data}');
    // Navigation can be handled via a callback or global key
  }

  void _onNotificationTap(NotificationResponse response) {
    _log('Local notification tapped: ${response.payload}');
  }

  // -- Notification storage (local) --

  /// Save a notification to local storage.
  static Future<void> _saveNotification(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_notificationsKey) ?? [];

    final notif = {
      'id': message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'title': message.notification?.title ?? 'Notification',
      'body': message.notification?.body ?? '',
      'data': message.data,
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    };

    existing.insert(0, jsonEncode(notif));

    // Keep max 50 notifications
    if (existing.length > 50) {
      existing.removeRange(50, existing.length);
    }

    await prefs.setStringList(_notificationsKey, existing);
  }

  /// Get stored notifications.
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_notificationsKey) ?? [];
    return stored
        .map((s) => jsonDecode(s) as Map<String, dynamic>)
        .toList();
  }

  /// Mark a notification as read.
  Future<void> markAsRead(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_notificationsKey) ?? [];

    final updated = stored.map((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      if (map['id'] == notificationId) {
        map['read'] = true;
      }
      return jsonEncode(map);
    }).toList();

    await prefs.setStringList(_notificationsKey, updated);
  }

  /// Mark all as read.
  Future<void> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_notificationsKey) ?? [];

    final updated = stored.map((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      map['read'] = true;
      return jsonEncode(map);
    }).toList();

    await prefs.setStringList(_notificationsKey, updated);
  }

  /// Get unread count.
  Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => n['read'] != true).length;
  }

  /// Clear all notifications.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);
  }

  /// Subscribe to a topic (e.g., order updates for a user).
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    _log('Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    _log('Unsubscribed from topic: $topic');
  }

  void _log(String message) {
    dev.log('[NOTIFICATION] $message', name: 'Kali');
  }
}
