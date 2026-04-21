import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_router.dart';
import 'core/services/notification_service.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<NotificationService>()) {
        Get.find<NotificationService>().processInitialMessage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      title: 'LMS Rise & Impact',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routeInformationParser: AppRouter.router.routeInformationParser,
      routerDelegate: AppRouter.router.routerDelegate,
      routeInformationProvider: AppRouter.router.routeInformationProvider,
      backButtonDispatcher: AppRouter.router.backButtonDispatcher,
    );
  }
}
