import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../config/constants.dart';

/// Background message handler (must be top-level function).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  // Handle background message processing
  // This runs in a separate isolate
}

/// Notification service for FCM push notifications
/// with high-priority emergency alert sounds.
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;

  /// Current FCM token.
  String? get fcmToken => _fcmToken;

  /// Initialize notification channels and request permissions.
  Future<void> initialize({
    required void Function(RemoteMessage message) onMessageReceived,
    required void Function(RemoteMessage message) onMessageOpenedApp,
  }) async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true, // For emergency bypass of DND
      provisional: false,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      return;
    }

    // Get FCM token
    _fcmToken = await _messaging.getToken();

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
    });

    // Set up background handler
    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    // Foreground messages
    FirebaseMessaging.onMessage.listen(onMessageReceived);

    // Message opened app (from background)
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);

    // Initialize local notifications
    await _initLocalNotifications();

    // Check for initial message (app opened from terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      onMessageOpenedApp(initialMessage);
    }
  }

  /// Set up local notification channels.
  Future<void> _initLocalNotifications() async {
    // Android: Emergency channel with max priority
    const androidEmergencyChannel = AndroidNotificationChannel(
      'eras_emergency',
      'Emergency Alerts',
      description: 'High-priority emergency response alerts',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      showBadge: true,
    );

    // Android: General channel
    const androidGeneralChannel = AndroidNotificationChannel(
      'eras_general',
      'General Notifications',
      description: 'General app notifications',
      importance: Importance.defaultImportance,
    );

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        androidEmergencyChannel,
      );
      await androidPlugin.createNotificationChannel(
        androidGeneralChannel,
      );
    }

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        requestCriticalPermission: true,
      ),
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap
      },
    );
  }

  /// Show a local emergency alert notification.
  Future<void> showEmergencyNotification({
    required String title,
    required String body,
    required String emergencyId,
    required String emergencyType,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'eras_emergency',
      'Emergency Alerts',
      channelDescription: 'High-priority emergency response alerts',
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: false,
      visibility: NotificationVisibility.public,
      ticker: 'Emergency Alert',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      emergencyId.hashCode,
      title,
      body,
      details,
      payload: jsonEncode({
        'emergencyId': emergencyId,
        'type': emergencyType,
      }),
    );
  }

  /// Show a general notification.
  Future<void> showGeneralNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'eras_general',
      'General Notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Send an emergency alert to a specific responder via FCM.
  /// In production, this should be called from a Cloud Function.
  Future<void> sendEmergencyAlert({
    required String token,
    required String emergencyId,
    required String? emergencyType,
    required double distance,
  }) async {
    // NOTE: Direct device-to-device FCM is deprecated.
    // This should be routed through a Cloud Function.
    // The Cloud Function would use Firebase Admin SDK to send:
    //
    // admin.messaging().send({
    //   token: token,
    //   notification: {
    //     title: '🚨 Emergency Alert',
    //     body: '$emergencyType emergency ${distance.toStringAsFixed(0)}m away',
    //   },
    //   data: {
    //     'emergencyId': emergencyId,
    //     'type': emergencyType,
    //     'distance': distance.toString(),
    //   },
    //   android: {
    //     priority: 'high',
    //     notification: { channel_id: 'eras_emergency' },
    //   },
    //   apns: {
    //     headers: { 'apns-priority': '10' },
    //     payload: { aps: { 'content-available': 1, 'sound': 'emergency.caf' } },
    //   },
    // });
  }

  /// Cancel a specific notification.
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications.
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Dispose resources.
  void dispose() {
    // Clean up listeners if needed
  }
}
