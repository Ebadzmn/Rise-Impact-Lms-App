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

// ─────────────────────────────────────────────
// Background handler — must be top-level function
// ─────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('[FCM] Background message received: ${message.messageId}');

  // Handle data-only messages (usually sent from backend APIs)
  if (message.notification == null && message.data.isNotEmpty) {
    final title = message.data['title']?.toString();
    final body = message.data['body']?.toString();

    if (title != null || body != null) {
      final localPlugin = FlutterLocalNotificationsPlugin();
      
      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      
      await localPlugin.initialize(
        settings: initSettings,
        onDidReceiveBackgroundNotificationResponse: _onBackgroundLocalNotificationTap,
      );

      const channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'Notifications for learning updates and alerts.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await localPlugin.show(
        id: message.messageId.hashCode,
        title: title ?? 'Notification',
        body: body ?? '',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }
}

// ─────────────────────────────────────────────
// NotificationService
// ─────────────────────────────────────────────
class NotificationService extends GetxService {
  // ── Instances ──────────────────────────────
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();

  // ── Observables ────────────────────────────
  final RxnString fcmToken = RxnString();
  final RxBool isTokenReady = false.obs;

  // ── Android channel ────────────────────────
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Notifications for learning updates and alerts.',
    importance: Importance.max, // max = heads-up on Android
    playSound: true,
    enableVibration: true,
  );

  // ── Internal state ─────────────────────────
  RemoteMessage? _initialMessage;
  bool _processedInitialMessage = false;

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _messageOpenedSub;

  // ═══════════════════════════════════════════
  // PUBLIC: init — called from main.dart / binding
  // ═══════════════════════════════════════════
  Future<NotificationService> init() async {
    await _requestPermissions();
    await _setForegroundPresentationOptions();
    await _configureLocalNotifications();
    await _waitForApnsIfNeeded();
    await _loadInitialToken();

    _listenTokenRefresh();
    _listenForegroundMessages();
    _listenNotificationTaps();

    // Capture cold-start message AFTER everything is set up
    _initialMessage = await _messaging.getInitialMessage();

    return this;
  }

  // ═══════════════════════════════════════════
  // PUBLIC: ensureToken
  // Call this before sending token to your API
  // ═══════════════════════════════════════════
  Future<String?> ensureToken() async {
    if (isTokenReady.value && (fcmToken.value?.isNotEmpty ?? false)) {
      return fcmToken.value;
    }
    await _loadInitialToken();
    return fcmToken.value;
  }

  // ═══════════════════════════════════════════
  // PUBLIC: processInitialMessage
  // Call this once from your first screen's initState / onReady
  // ═══════════════════════════════════════════
  Future<void> processInitialMessage() async {
    if (_processedInitialMessage) return;
    _processedInitialMessage = true;

    final message = _initialMessage;
    _initialMessage = null;

    if (message != null) {
      // Small delay so the router is fully mounted
      await Future<void>.delayed(const Duration(milliseconds: 500));
      _navigateFromPayload(message.data);
    }
  }

  // ═══════════════════════════════════════════
  // PRIVATE: permissions
  // ═══════════════════════════════════════════
  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: false,
    );

    debugPrint('[FCM] Permission status: ${settings.authorizationStatus.name}');

    // Android 13+ runtime permission
    if (GetPlatform.isAndroid) {
      final androidPlugin = _localPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.requestNotificationsPermission();
    }
  }

  // ═══════════════════════════════════════════
  // PRIVATE: foreground presentation (iOS)
  // ═══════════════════════════════════════════
  Future<void> _setForegroundPresentationOptions() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ═══════════════════════════════════════════
  // PRIVATE: local notifications setup
  // ═══════════════════════════════════════════
  Future<void> _configureLocalNotifications() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        // Use default system sound — change to custom asset name if needed
        defaultPresentSound: true,
      ),
    );

    await _localPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundLocalNotificationTap,
    );

    // Create Android channel
    await _localPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  // ═══════════════════════════════════════════
  // PRIVATE: APNs wait (iOS only)
  // ═══════════════════════════════════════════
  Future<void> _waitForApnsIfNeeded() async {
    if (!GetPlatform.isIOS) return;

    // Give OS time to register, then verify APNs token
    await Future<void>.delayed(const Duration(seconds: 1));

    final apnsToken = await _messaging.getAPNSToken();

    if (kDebugMode) {
      if (apnsToken == null || apnsToken.isEmpty) {
        debugPrint(
          '[FCM] ⚠️  APNs token missing — push will not work on simulator. '
          'Run on a physical device with Push Notifications capability.',
        );
      } else {
        debugPrint('[FCM] APNs token: $apnsToken');
      }
    }
  }

  // ═══════════════════════════════════════════
  // PRIVATE: FCM token loading
  // ═══════════════════════════════════════════
  Future<void> _loadInitialToken() async {
    try {
      final token = await _messaging.getToken();
      _handleToken(token);
    } catch (e, st) {
      isTokenReady.value = false;
      fcmToken.value = null;
      debugPrint('[FCM] ❌ Token fetch failed: $e\n$st');
    }
  }

  void _listenTokenRefresh() {
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _messaging.onTokenRefresh.listen((token) {
      debugPrint('[FCM] Token refreshed');
      _handleToken(token);
    });
  }

  void _handleToken(String? token) {
    if (token == null || token.isEmpty) {
      isTokenReady.value = false;
      fcmToken.value = null;
      debugPrint('[FCM] Token unavailable');
      return;
    }

    fcmToken.value = token;
    isTokenReady.value = true;
    debugPrint('[FCM] Token ready: $token');

    // Persist token so your API layer can pick it up
    try {
      Get.find<StorageService>().saveDeviceToken(token);
    } catch (_) {
      // StorageService not registered yet during early init — safe to ignore
    }
  }

  // ═══════════════════════════════════════════
  // PRIVATE: foreground messages
  // ═══════════════════════════════════════════
  void _listenForegroundMessages() {
    _foregroundSub?.cancel();
    _foregroundSub = FirebaseMessaging.onMessage.listen(_showLocalNotification);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    // Prefer notification fields; fall back to data map
    final title =
        (message.notification?.title ?? message.data['title'])?.toString() ??
        'Notification';
    final body =
        (message.notification?.body ?? message.data['body'])?.toString() ?? '';

    await _localPlugin.show(
      // Use a stable id based on messageId so duplicates are replaced
      id: message.messageId.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          // Show as heads-up notification
          fullScreenIntent: false,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
          interruptionLevel: InterruptionLevel.active,
        ),
      ),
      // Encode full data map so we can navigate on tap
      payload: jsonEncode(message.data),
    );
  }

  // ═══════════════════════════════════════════
  // PRIVATE: notification taps
  // ═══════════════════════════════════════════

  // App opened from background/killed via FCM tap
  void _listenNotificationTaps() {
    _messageOpenedSub?.cancel();
    _messageOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM] App opened from notification');
      _navigateFromPayload(message.data);
    });
  }

  // Local notification tapped (foreground)
  void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload);
      if (data is Map<String, dynamic>) {
        _navigateFromPayload(data);
        return;
      }
    } catch (_) {
      // Not JSON — treat as raw route string
    }

    _navigateFromPayload({'route': payload});
  }

  // ═══════════════════════════════════════════
  // PRIVATE: navigation
  // ═══════════════════════════════════════════
  void _navigateFromPayload(Map<String, dynamic> data) {
    final raw = data['route']?.toString().trim();

    final route = (raw == null || raw.isEmpty)
        ? AppRoutes.notifications
        : (raw.startsWith('/') ? raw : '/$raw');

    debugPrint('[FCM] Navigating to: $route');

    try {
      AppRouter.router.go(route);
    } catch (e) {
      debugPrint('[FCM] Navigation error: $e');
      // Fallback to notifications screen
      AppRouter.router.go(AppRoutes.notifications);
    }
  }

  // ═══════════════════════════════════════════
  // Cleanup
  // ═══════════════════════════════════════════
  @override
  void onClose() {
    _tokenRefreshSub?.cancel();
    _foregroundSub?.cancel();
    _messageOpenedSub?.cancel();
    super.onClose();
  }
}

// ─────────────────────────────────────────────
// Background local notification tap handler
// Must be top-level function
// ─────────────────────────────────────────────
@pragma('vm:entry-point')
void _onBackgroundLocalNotificationTap(NotificationResponse response) {
  // Minimal handling — app will process on next foreground
  debugPrint('[FCM] Background local notification tapped: ${response.payload}');
}
