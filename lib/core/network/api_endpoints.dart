class ApiEndpoints {
  ApiEndpoints._();

  // Base URL – change this to your actual backend
  static const String baseUrl = 'http://10.10.7.33:5003/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String signup = '/users';
  static const String verifyOtp = '/auth/verify-email';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';

  // User
  static const String profile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String changePassword = '/auth/change-password';
  static const String studentHome = '/student/home';

  // Courses
  static const String getCourses = '/courses';
  static const String courseOptions = '/courses/options';
  static const String bulkEnrollment = '/enrollments/bulk';

  // Community
  static const String communityPosts = '/community/posts';
  static const String myPosts = '/community/posts/my-posts';
  static String communityPostDetails(String id) => '/community/posts/$id';
  static String editPost(String id) => '/community/posts/$id';
  static String toggleLike(String id) => '/community/posts/$id/like';
  static String addReply(String id) => '/community/posts/$id/replies';
  static String editReply(String id) => '/community/replies/$id';
  static String deletePost(String id) => '/community/posts/$id';
  static String deleteReply(String id) => '/community/replies/$id';

  // Gamification
  static const String myBadges = '/gamification/my-badges';

  // Legal
  static const String legal = '/legal';
  static String legalDetails(String slug) => '/legal/$slug';
}
