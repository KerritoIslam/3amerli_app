import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:amerli_app/features/auth/app/bloc/auth_bloc.dart';
import 'package:amerli_app/core/config/injection.dart';
import 'package:amerli_app/core/storage/local_storage.dart';

// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Background message received: ${message.messageId}');
  }
  // Handle background message here
  // This will show a local notification when app is in background
  final notificationService = NotificationService();
  await notificationService._showNotificationFromRemote(message);
}

class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  // Callback for handling notification taps
  static void Function(RemoteMessage)? onNotificationTap;

  // Token registration retry state
  static Timer? _tokenRegistrationRetryTimer;
  static int _tokenRegistrationAttempts = 0;
  static const int _maxRetryAttempts = 5;

  // Offline queue for token registration
  static final List<String> _tokenQueue = [];
  static bool _isProcessingQueue = false;

  // Key used to persist FCM token in SharedPreferences
  static const String _prefsFcmTokenKey = 'fcm_token';

  // Request Android 13+ runtime permissions
  Future<void> _requestNotificationPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;

      if (status.isDenied) {
        // Show educational dialog before requesting permission
        await _showPermissionDialog();

        final result = await Permission.notification.request();
        if (result.isPermanentlyDenied) {
          // User selected "Don't ask again" - guide to settings
          await _showSettingsDialog();
        }
      } else if (status.isPermanentlyDenied) {
        // Previously denied - guide to settings
        await _showSettingsDialog();
      }
    }
  }

  // Show educational dialog about notifications
  Future<void> _showPermissionDialog() async {
    // This would be shown in your app's UI context
    // For now, we'll just log it
    if (kDebugMode) {
      print('Showing permission education dialog');
    }
  }

  // Show dialog to guide user to settings
  Future<void> _showSettingsDialog() async {
    if (kDebugMode) {
      print('Guiding user to app settings for notifications');
    }
    // In a real app, you would show a dialog with a button that opens app settings
    // await openAppSettings();
  }

  // Create multiple notification channels for better categorization
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      // Orders channel - High importance
      const ordersChannel = AndroidNotificationChannel(
        'orders_channel',
        'Orders',
        description: 'Order updates and notifications',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      // Promotions channel - Default importance
      const promotionsChannel = AndroidNotificationChannel(
        'promotions_channel',
        'Promotions',
        description: 'Special offers and promotions',
        importance: Importance.defaultImportance,
        playSound: true,
        enableVibration: false,
      );

      // System channel - High importance
      const systemChannel = AndroidNotificationChannel(
        'system_channel',
        'System',
        description: 'System notifications and updates',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      // Create all channels
      await androidPlugin.createNotificationChannel(ordersChannel);
      await androidPlugin.createNotificationChannel(promotionsChannel);
      await androidPlugin.createNotificationChannel(systemChannel);
    }
  }

  Future<void> init() async {
    // Request Android 13+ runtime permissions first
    await _requestNotificationPermissions();

    // Local notifications initialization
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);
    await _local.initialize(initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped);

    // Create multiple notification channels for better categorization
    await _createNotificationChannels();

    // iOS permissions are requested via FirebaseMessaging.requestPermission() below

    // Firebase Messaging wiring (optional): token retrieval and background handler
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Obtain FCM token (if Firebase is configured).
      String? token = await messaging.getToken();
      if (kDebugMode) print('FCM token: $token');
      if (token != null && token.isNotEmpty) {
        await _saveFcmTokenLocal(token);
      }

      // Handle token refresh with retry logic
      messaging.onTokenRefresh.listen((newToken) async {
        if (kDebugMode) print('FCM token refreshed: $newToken');
        await _saveFcmTokenLocal(newToken);
        // Register new token with backend when user is logged in
        registerTokenWithRetry(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) print('Foreground message: ${message.messageId}');
        _showNotificationFromRemote(message);
      });

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) print('Notification tapped: ${message.messageId}');
        if (onNotificationTap != null) {
          onNotificationTap!(message);
        }
      });

      // Handle notification taps when app is completely closed
      RemoteMessage? initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        if (kDebugMode) {
          print('App opened from notification: ${initialMessage.messageId}');
        }
        if (onNotificationTap != null) {
          onNotificationTap!(initialMessage);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firebase Messaging not configured or initialization failed: $e');
      }
    }
  }

  // Register token with exponential backoff retry
  Future<void> registerTokenWithRetry(String token) async {
    _tokenRegistrationAttempts = 0;
    await _attemptTokenRegistration(token);
  }

  Future<void> _attemptTokenRegistration(String token) async {
    if (_tokenRegistrationAttempts >= _maxRetryAttempts) {
      if (kDebugMode) {
        print('Max retry attempts reached for token registration');
      }
      return;
    }

    try {
      // Check connectivity first
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Queue token for later when offline
        if (!_tokenQueue.contains(token)) {
          _tokenQueue.add(token);
          if (kDebugMode) {
            print('Token queued for registration (offline): $token');
          }
        }
        return;
      }

      final authBloc = sl<AuthBloc>();
      await authBloc.handleTokenRefresh(token);

      // Reset retry attempts on success
      _tokenRegistrationAttempts = 0;

      // Process any queued tokens
      await _processTokenQueue();
    } catch (e) {
      _tokenRegistrationAttempts++;
      if (kDebugMode) {
        print(
            'Token registration attempt $_tokenRegistrationAttempts failed: $e');
      }

      if (_tokenRegistrationAttempts < _maxRetryAttempts) {
        // Exponential backoff: 2^attempt seconds, max 30 seconds
        final delay =
            Duration(seconds: (1 << _tokenRegistrationAttempts).clamp(2, 30));
        _tokenRegistrationRetryTimer = Timer(delay, () {
          _attemptTokenRegistration(token);
        });
      }
    }
  }

  // Process queued tokens when connectivity is restored
  Future<void> _processTokenQueue() async {
    if (_isProcessingQueue || _tokenQueue.isEmpty) return;

    _isProcessingQueue = true;

    try {
      final tokensToProcess = List<String>.from(_tokenQueue);
      _tokenQueue.clear();

      for (final token in tokensToProcess) {
        await _attemptTokenRegistration(token);
        // Small delay between processing
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } finally {
      _isProcessingQueue = false;
    }
  }

  Future<void> _showNotificationFromRemote(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final title = notification.title ?? '';
    final body = notification.body ?? '';

    // Determine appropriate channel based on message data
    String channelId = 'default_channel';
    if (message.data.containsKey('type')) {
      final type = message.data['type'];
      switch (type) {
        case 'order':
          channelId = 'orders_channel';
          break;
        case 'promotion':
          channelId = 'promotions_channel';
          break;
        case 'system':
          channelId = 'system_channel';
          break;
      }
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: _getChannelImportance(channelId),
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final platformDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _local.show(
      message.hashCode,
      title,
      body,
      platformDetails,
      payload: _messageToPayload(message),
    );
  }

  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'orders_channel':
        return 'Orders';
      case 'promotions_channel':
        return 'Promotions';
      case 'system_channel':
        return 'System';
      default:
        return 'Default';
    }
  }

  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'orders_channel':
        return 'Order updates and notifications';
      case 'promotions_channel':
        return 'Special offers and promotions';
      case 'system_channel':
        return 'System notifications and updates';
      default:
        return 'Default notifications';
    }
  }

  Importance _getChannelImportance(String channelId) {
    switch (channelId) {
      case 'orders_channel':
        return Importance.high;
      case 'promotions_channel':
        return Importance.defaultImportance;
      case 'system_channel':
        return Importance.high;
      default:
        return Importance.high;
    }
  }

  // Convert RemoteMessage to JSON string for payload with proper encoding
  String _messageToPayload(RemoteMessage message) {
    final payload = {
      'messageId': message.messageId,
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': message.data,
    };
    return jsonEncode(payload);
  }

  Future<void> showLocalNotification(
      {required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default',
      channelDescription: 'Default notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    final platformDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _local.show(0, title, body, platformDetails);
  }

  // Handle notification taps from local notifications with proper JSON parsing
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null && onNotificationTap != null) {
      try {
        final payload = response.payload!;
        if (kDebugMode) {
          print('Local notification tapped with payload: $payload');
        }

        // Proper JSON parsing
        final Map<String, dynamic> payloadData = jsonDecode(payload);

        final mockMessage = RemoteMessage(
          messageId: payloadData['messageId']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          data: Map<String, dynamic>.from(payloadData['data'] ?? {}),
          notification: RemoteNotification(
            title: payloadData['title']?.toString() ?? '',
            body: payloadData['body']?.toString() ?? '',
          ),
        );

        onNotificationTap!(mockMessage);
      } catch (e) {
        if (kDebugMode) print('Error parsing notification payload: $e');
      }
    }
  }

  // Get current FCM token
  Future<String?> getFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) return token;
      // Fallback to locally stored token if Firebase cannot provide one
      return await readStoredFcmToken();
    } catch (e) {
      if (kDebugMode) print('Error getting FCM token: $e');
      // Fallback to locally stored token
      return await readStoredFcmToken();
    }
  }

  // Set up notification tap callback
  void setOnNotificationTap(void Function(RemoteMessage) callback) {
    onNotificationTap = callback;
  }

  // Persist FCM token locally
  Future<void> _saveFcmTokenLocal(String token) async {
    try {
      final storage = sl<LocalStorage>();
      await storage.setString(_prefsFcmTokenKey, token);
    } catch (_) {}
  }

  // Read stored FCM token
  Future<String?> readStoredFcmToken() async {
    try {
      final storage = sl<LocalStorage>();
      return storage.getString(_prefsFcmTokenKey);
    } catch (_) {
      return null;
    }
  }

  // Clear stored FCM token
  Future<void> clearStoredFcmToken() async {
    try {
      final storage = sl<LocalStorage>();
      await storage.remove(_prefsFcmTokenKey);
    } catch (_) {}
  }

  // Cleanup resources
  static void dispose() {
    _tokenRegistrationRetryTimer?.cancel();
    _tokenQueue.clear();
  }
}
