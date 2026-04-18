import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_riseandimpact/features/topics/topics_page.dart';

import '../data/models/quiz_model.dart';
import 'app_routes.dart';
import '../features/splash/splash_page.dart';
import '../features/splash/splash_binding.dart';
import '../features/welcome/welcome_page.dart';
import '../features/welcome/welcome_binding.dart';
import '../features/auth/login/login_page.dart';
import '../features/auth/signup/signup_page.dart';
import '../features/auth/otp/otp_page.dart';
import '../features/auth/forgot_password/forgot_password_page.dart';
import '../features/auth/forgot_password/forgot_password_otp_page.dart';
import '../features/auth/forgot_password/reset_password_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/notifications/notifications_page.dart';
import '../features/courses/course_details_page.dart';
import "../features/courses/course_video_page.dart";
import "../features/courses/resource_details_page.dart";
import "../features/courses/pages/lesson_completion_page.dart";
import "../features/courses/pages/quiz_page.dart";
import "../features/courses/pages/course_complete_page.dart";
import '../features/courses/course_details_binding.dart';
import '../features/courses/lesson_binding.dart';
import '../features/courses/lesson_page.dart';
import '../features/courses/quiz_binding.dart';
import '../features/courses/pages/quiz_result_page.dart';
import '../features/dashboard/dashboard_binding.dart';
import '../features/community/community_page.dart';
import '../features/community/community_binding.dart';
import '../features/community/post_details_page.dart';
import '../features/community/post_details_binding.dart';
import '../features/community/create_post_page.dart';
import '../features/community/create_post_binding.dart';
import '../features/home/home_page.dart';
import '../features/courses/courses_page.dart';
import '../features/progress/progress_page.dart';
import '../features/community/my_posts_page.dart';
import '../features/community/my_posts_binding.dart';
import '../features/profile/profile_page.dart';
import '../features/community/edit_post_page.dart';
import '../features/community/edit_post_binding.dart';
import '../features/community/models/post_model.dart';
import '../features/profile/profile_binding.dart';
import '../features/legal/legal_details_page.dart';
import '../features/legal/legal_details_binding.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = Get.key;

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
          return LoginPage();
        },
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) {
          return SignupPage();
        },
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OtpPage(email: email);
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) {
          return ForgotPasswordPage();
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPasswordOtp,
        builder: (context, state) {
          return const ForgotPasswordOtpPage();
        },
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) {
          return ResetPasswordPage();
        },
      ),
      GoRoute(
        path: AppRoutes.topics,
        builder: (context, state) {
          return const TopicsPage();
        },
      ),
      // Stateful navigation based on:
      // https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // Return the widget that implements the custom shell (e.g. a BottomNavigationBar).
          // The [StatefulNavigationShell] is passed to be able to navigate to other branches.
          DashboardBinding().dependencies();
          return DashboardPage(navigationShell: navigationShell);
        },
        branches: [
          // The route branch for the 1st Tab
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                builder: (BuildContext context, GoRouterState state) =>
                    const HomePage(),
                routes: [
                  GoRoute(
                    path: 'notifications', // /home/notifications
                    builder: (context, state) {
                      return const NotificationsPage();
                    },
                  ),
                ],
              ),
            ],
          ),

          // The route branch for the 2nd Tab
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/courses', // Explicit path for courses tab
                builder: (BuildContext context, GoRouterState state) =>
                    const CoursesPage(),
                routes: [
                  GoRoute(
                    path: 'details', // /courses/details
                    builder: (context, state) {
                      const identifier = 'default'; // Fallback
                      CourseDetailsBinding(identifier: identifier).dependencies();
                      return const CourseDetailsPage(identifier: identifier);
                    },
                  ),
                  GoRoute(
                    name: AppRoutes.studentCourseDetails,
                    path: ':slug/student-detail', // /courses/:slug/student-detail
                    builder: (context, state) {
                      final identifier = state.pathParameters['slug'] ?? '';
                      CourseDetailsBinding(identifier: identifier).dependencies();
                      return CourseDetailsPage(identifier: identifier);
                    },
                  ),
                  GoRoute(
                    name: AppRoutes.lessonContent,
                    path: ':courseId/lessons/:lessonId',
                    builder: (context, state) {
                      final courseId = state.pathParameters['courseId'] ?? '';
                      final lessonId = state.pathParameters['lessonId'] ?? '';
                      LessonBinding(courseId: courseId, lessonId: lessonId).dependencies();
                      return LessonPage(courseId: courseId, lessonId: lessonId);
                    },
                  ),
                  GoRoute(
                    path: 'video',
                    builder: (context, state) {
                      return const CourseVideoPage();
                    },
                  ),
                  GoRoute(
                    path: 'resource-details',
                    builder: (context, state) {
                      return const ResourceDetailsPage();
                    },
                  ),
                  GoRoute(
                    path: 'lesson-completion',
                    builder: (context, state) {
                      return const LessonCompletionPage();
                    },
                  ),
                  GoRoute(
                    name: AppRoutes.quiz,
                    path: 'quiz/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      QuizBinding(quizId: id).dependencies();
                      return QuizPage(quizId: id);
                    },
                  ),
                  GoRoute(
                    name: AppRoutes.quizResult,
                    path: 'quiz-result',
                    builder: (context, state) {
                      final result = state.extra as QuizResultModel;
                      return QuizResultPage(result: result);
                    },
                  ),
                  GoRoute(
                    path: 'complete',
                    builder: (context, state) {
                      return const CourseCompletePage();
                    },
                  ),
                ],
              ),
            ],
          ),

          // The route branch for the 3rd Tab
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/progress',
                builder: (BuildContext context, GoRouterState state) =>
                    const ProgressPage(),
              ),
            ],
          ),

          // The route branch for the 4th Tab
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/community',
                builder: (BuildContext context, GoRouterState state) {
                  CommunityBinding().dependencies();
                  return const CommunityPage();
                },
                routes: [
                  GoRoute(
                    name: AppRoutes.postDetails,
                    path: 'post-details/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      PostDetailsBinding(postId: id).dependencies();
                      return const PostDetailsPage();
                    },
                  ),
                  GoRoute(
                    path: 'create-post',
                    builder: (context, state) {
                      CreatePostBinding().dependencies();
                      return const CreatePostPage();
                    },
                  ),
                  GoRoute(
                    path: 'my-posts',
                    builder: (context, state) {
                      MyPostsBinding().dependencies();
                      return const MyPostsPage();
                    },
                  ),
                  GoRoute(
                    path: 'edit-post',
                    builder: (context, state) {
                      final post = state.extra as PostModel;
                      EditPostBinding(post: post).dependencies();
                      return const EditPostPage();
                    },
                  ),
                ],
              ),
            ],
          ),

          // The route branch for the 5th Tab
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/profile',
                builder: (BuildContext context, GoRouterState state) {
                  ProfileBinding().dependencies();
                  return const ProfilePage();
                },
                routes: [
                  GoRoute(
                    name: AppRoutes.legalDetails,
                    path: 'legal/:slug',
                    builder: (context, state) {
                      final slug = state.pathParameters['slug'] ?? '';
                      LegalDetailsBinding(slug: slug).dependencies();
                      return const LegalDetailsPage();
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
