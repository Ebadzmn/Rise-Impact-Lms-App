abstract class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp';
  static const String topics = '/topics';
  static const String welcome = '/welcome';
  static const String home = '/home';
  static const String notifications = '/home/notifications';
  static const String courseDetails = '/courses/details';
  static const String courseVideo = '/courses/video';
  static const String resourceDetails = '/courses/resource-details';
  static const String lessonCompletion = '/courses/lesson-completion';
  static const String quiz = '/courses/quiz';
  static const String courseComplete = '/courses/complete';
  static const String postDetails = '/community/post-details/:id';
  static const String createPost = '/community/create-post';
  static const String myPosts = '/community/my-posts';
  static const String editPost = '/community/edit-post';
  static const String legalDetails = '/profile/legal/:slug';
}
