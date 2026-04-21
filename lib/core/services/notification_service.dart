import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../firebase_options.dart';
import '../../routes/app_router.dart';
import '../../routes/app_routes.dart';
import 'storage_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    debugPrint('Background FCM message: ${message.messageId}');
  }
}

class NotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final RxnString fcmToken = RxnString();
  final RxBool isTokenReady = false.obs;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Notifications for learning updates and alerts.',
    importance: Importance.high,
  );

  RemoteMessage? _initialMessage;
  bool _processedInitialMessage = false;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedAppSubscription;

  Future<NotificationService> init() async {
    await _requestPermissions();
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    await _configureLocalNotifications();

    // On iOS, wait for the APNs token to be ready before requesting the FCM token
    if (GetPlatform.isIOS) {
      await Future<void>.delayed(
        const Duration(seconds: 1),
      ); // allow OS to register
      final apnsToken = await _messaging.getAPNSToken();
      if (kDebugMode) {
        debugPrint('APNs Token: $apnsToken');
        if (apnsToken == null || apnsToken.isEmpty) {
          debugPrint(
            'APNs token is missing. iOS push notifications will not arrive until you run on a physical device with Push Notifications capability and APNs configured in Firebase.',
          );
        }
      }
    }

    await _loadInitialToken();

    _listenToTokenRefresh();
    _listenForForegroundMessages();
    _listenForNotificationTaps();
    _initialMessage = await _messaging.getInitialMessage();

    return this;
  }

  Future<String?> ensureToken() async {
    if (isTokenReady.value && (fcmToken.value?.isNotEmpty ?? false)) {
      return fcmToken.value;
    }

    await _loadInitialToken();
    return fcmToken.value;
  }

  Future<void> processInitialMessage() async {
    if (_processedInitialMessage) {
      return;
    }

    _processedInitialMessage = true;

    final message = _initialMessage;
    _initialMessage = null;

    if (message != null) {
      _openTargetFromMessage(message);
    }
  }

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      debugPrint('Notification permission: ${settings.authorizationStatus}');
    }

    final androidImplementation = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.requestNotificationsPermission();
  }

  Future<void> _configureLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      ),
    );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  Future<void> _loadInitialToken() async {
    try {
      final token = await _messaging.getToken();
      await _updateToken(token);
    } catch (error) {
      isTokenReady.value = false;
      fcmToken.value = null;
      debugPrint('FCM token fetch failed: $error');
    }
  }

  void _listenToTokenRefresh() {
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((token) async {
      await _updateToken(token, isRefresh: true);
    });
  }

  void _listenForForegroundMessages() {
    _foregroundMessageSubscription?.cancel();
    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(
      _showForegroundNotification,
    );
  }

  void _listenForNotificationTaps() {
    _messageOpenedAppSubscription?.cancel();
    _messageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _openTargetFromMessage,
    );
  }

  Future<void> _updateToken(String? token, {bool isRefresh = false}) async {
    final storage = Get.find<StorageService>();

    if (token == null || token.isEmpty) {
      isTokenReady.value = false;
      fcmToken.value = null;
      debugPrint('FCM Token unavailable');
      return;
    }

    fcmToken.value = token;
    isTokenReady.value = true;
    storage.saveDeviceToken(token);

    debugPrint('FCM Token: $token');

    if (isRefresh && kDebugMode) {
      debugPrint('FCM token refreshed and stored.');
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final title =
        message.notification?.title ??
        message.data['title']?.toString() ??
        'Notification';
    final body =
        message.notification?.body ?? message.data['body']?.toString() ?? '';

    await _localNotificationsPlugin.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        _navigateFromPayload(decoded);
        return;
      }
    } catch (_) {
      // Treat payload as a raw route when it is not JSON.
    }

    _navigateFromPayload({'route': payload});
  }

  void _openTargetFromMessage(RemoteMessage message) {
    _navigateFromPayload(message.data);
  }

  void _navigateFromPayload(Map<String, dynamic> data) {
    final routeValue = data['route']?.toString().trim();
    final route = routeValue == null || routeValue.isEmpty
        ? AppRoutes.notifications
        : (routeValue.startsWith('/') ? routeValue : '/$routeValue');

    AppRouter.router.go(route);
  }

  @override
  void onClose() {
    _tokenRefreshSubscription?.cancel();
    _foregroundMessageSubscription?.cancel();
    _messageOpenedAppSubscription?.cancel();
    super.onClose();
  }
}
