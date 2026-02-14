import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_riseandimpact/features/topics/topics_page.dart';

import 'app_routes.dart';
import '../features/splash/splash_page.dart';
import '../features/splash/splash_binding.dart';
import '../features/welcome/welcome_page.dart';
import '../features/welcome/welcome_binding.dart';
import '../features/auth/login/login_page.dart';
import '../features/auth/signup/signup_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/notifications/notifications_page.dart';
import '../features/courses/course_details_page.dart';
import "../features/courses/course_video_page.dart";
import '../features/dashboard/dashboard_binding.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) {
          SplashBinding().dependencies();
          return const SplashPage();
        },
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) {
          WelcomeBinding().dependencies();
          return const WelcomePage();
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) {
          // Bindings can be done here or in the screen itself if using GetView
          return const LoginPage();
        },
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) {
          return const SignupPage();
        },
      ),
      GoRoute(
        path: AppRoutes.topics,
        builder: (context, state) {
          return const TopicsPage();
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) {
          DashboardBinding().dependencies();
          return const DashboardPage();
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) {
          return const NotificationsPage();
        },
      ),
      GoRoute(
        path: AppRoutes.courseDetails,
        builder: (context, state) {
          return const CourseDetailsPage();
        },
      ),
      GoRoute(
        path: AppRoutes.courseVideo,
        builder: (context, state) {
          return const CourseVideoPage();
        },
      ),
    ],
  );
}
