import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../main.dart' show isFirebaseInitialized;

/// Top-level handler for background messages (required by firebase_messaging).
/// Must be a top-level function — cannot be a class method.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
}

/// Manages push notifications end-to-end:
/// - Permission request
/// - FCM token lifecycle (get, save, refresh)
/// - Foreground / background / terminated message handling
/// - Local notification display when app is in foreground
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Callback when user taps a notification
  void Function(String type, String? id)? onNotificationTap;

  // ── Android notification channel ──
  static const _androidChannel = AndroidNotificationChannel(
    'balam_default',
    'Balam Notifications',
    description: 'Insights, tracking reminders, consultation updates',
    importance: Importance.high,
  );

  // ── Initialize ──

  Future<void> init({required String? userId}) async {
    if (!isFirebaseInitialized || _initialized) return;
    _initialized = true;

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[FCM] User denied notification permissions');
      return;
    }

    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    // Get & save token
    final token = await _messaging.getToken();
    if (token != null && userId != null) {
      await _saveToken(userId, token);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      if (userId != null) _saveToken(userId, newToken);
    });

    // Init local notifications
    await _initLocalNotifications();

    // Create Android channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // Foreground messages → show local notification
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // User taps notification while app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a terminated-state notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // iOS foreground presentation options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('[FCM] Notification service initialized. Token: ${token?.substring(0, 20)}...');
  }

  // ── Token management ──

  Future<void> _saveToken(String userId, String token) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'fcmToken': token});
      debugPrint('[FCM] Token saved for user $userId');
    } catch (e) {
      debugPrint('[FCM] Failed to save token: $e');
    }
  }

  /// Remove token on sign-out to stop receiving notifications.
  Future<void> clearToken(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'fcmToken': FieldValue.delete()});
      await _messaging.deleteToken();
      debugPrint('[FCM] Token cleared for user $userId');
    } catch (e) {
      debugPrint('[FCM] Failed to clear token: $e');
    }
  }

  // ── Local notifications init ──

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // Already requested via FCM
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        // Parse payload and route
        final payload = response.payload ?? '';
        final parts = payload.split('|');
        final type = parts.isNotEmpty ? parts[0] : '';
        final id = parts.length > 1 ? parts[1] : null;
        onNotificationTap?.call(type, id);
      },
    );
  }

  // ── Message handlers ──

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] Foreground: ${message.notification?.title}');

    final notification = message.notification;
    if (notification == null) return;

    // Show local notification so user sees it in foreground
    _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
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
      payload: '${message.data['type'] ?? ''}|${message.data['insightId'] ?? message.data['consultationId'] ?? ''}',
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('[FCM] Notification tapped: ${message.data}');
    final type = message.data['type'] as String? ?? '';
    final id = message.data['insightId'] as String? ??
        message.data['consultationId'] as String? ??
        '';
    onNotificationTap?.call(type, id);
  }

  // ── Subscribe to topics ──

  Future<void> subscribeToTopic(String topic) async {
    if (!isFirebaseInitialized) return;
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    if (!isFirebaseInitialized) return;
    await _messaging.unsubscribeFromTopic(topic);
  }
}
