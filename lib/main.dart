import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'features/notifications/notifications_controller.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Global Services
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => NotificationService().init());
  Get.put(NotificationsController(), permanent: true);

  runApp(const App());
}
