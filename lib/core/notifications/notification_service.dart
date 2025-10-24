import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Local notifications initialization
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _local.initialize(initSettings);

    // Android 8+ requires a notification channel before showing notifications
    const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
      'default_channel',
      'Default',
      description: 'Default notifications',
      importance: Importance.high,
      playSound: true,
    );
    final androidPlugin = _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(defaultChannel);
      // Note: On Android 13+ you may need to request the POST_NOTIFICATIONS permission
      // via a separate permissions flow if targeting API 33+. (Handled at app level if needed.)
    }

    // iOS permissions are requested via FirebaseMessaging.requestPermission() below

    // Firebase Messaging wiring (optional): token retrieval and background handler
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Request permission via firebase_messaging (iOS/macOS unified flow)
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (kDebugMode) {
        print('User granted permission: ${settings.authorizationStatus}');
      }

      // Ensure iOS shows notifications while app is in foreground
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Obtain FCM token (if Firebase is configured).
      String? token = await messaging.getToken();
      if (kDebugMode) print('FCM token: $token');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) print('Foreground message: ${message.messageId}');
        _showNotificationFromRemote(message);
      });
    } catch (e) {
      if (kDebugMode) print('Firebase Messaging not configured or initialization failed: $e');
    }
  }

  // Local permission request is handled by FirebaseMessaging.requestPermission() when available.

  Future<void> _showNotificationFromRemote(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final title = notification.title ?? '';
    final body = notification.body ?? '';

    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default',
      channelDescription: 'Default notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final platformDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _local.show(
      message.hashCode,
      title,
      body,
      platformDetails,
    );
  }

  Future<void> showLocalNotification({required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default',
      channelDescription: 'Default notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    final platformDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _local.show(0, title, body, platformDetails);
  }
}
