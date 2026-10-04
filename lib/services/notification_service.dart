import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId =
      'smart_tourist_safety_channel';

  static const String _channelName =
      'Smart Tourist Safety';

  static const String _channelDescription =
      'Safety and travel notifications';

  // ------------------------------------------------------------
  // INITIALIZE
  // ------------------------------------------------------------

  static Future<void> initialize() async {
    // Notifications are not initialized through the
    // Android implementation when running on web.
    if (kIsWeb) {
      return;
    }

    const AndroidInitializationSettings
        androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings settings =
        InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings: settings,
    );

    await _requestAndroidPermission();
  }

  // ------------------------------------------------------------
  // ANDROID NOTIFICATION PERMISSION
  // ------------------------------------------------------------

  static Future<void>
      _requestAndroidPermission() async {
    final AndroidFlutterLocalNotificationsPlugin?
        androidPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) {
      return;
    }

    await androidPlugin
        .requestNotificationsPermission();
  }

  // ------------------------------------------------------------
  // SHOW GENERAL NOTIFICATION
  // ------------------------------------------------------------

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) {
      return;
    }

    const AndroidNotificationDetails
        androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription:
          _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails details =
        NotificationDetails(
      android: androidDetails,
    );

    try {
      await _notifications.show(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .remainder(100000),
        title: title,
        body: body,
        notificationDetails: details,
      );
    } catch (_) {
      // Notification failure must not crash
      // the main application.
    }
  }

  // ------------------------------------------------------------
  // SAFETY ALERT
  // ------------------------------------------------------------

  static Future<void> showSafetyAlert({
    required String title,
    required String message,
  }) async {
    await showNotification(
      title: '⚠️ $title',
      body: message,
    );
  }

  // ------------------------------------------------------------
  // GEOFENCE NOTIFICATION
  // ------------------------------------------------------------

  static Future<void>
      showGeoFenceNotification({
    required String placeName,
  }) async {
    await showNotification(
      title: '📍 Tourist Zone',
      body:
          'You have entered the tourist zone: $placeName.',
    );
  }

  // ------------------------------------------------------------
  // TEST NOTIFICATION
  // ------------------------------------------------------------

  static Future<void>
      showTestNotification() async {
    await showNotification(
      title: 'Smart Tourist Safety',
      body:
          'Notifications are working successfully!',
    );
  }
}