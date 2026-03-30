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
  static const String studentProgress = '/student/progress';
  static const String activityCalendar = '/activity/calendar';

  // Courses
  static const String getCourses = '/courses';
  static const String browseCourses = '/courses/browse';
  static const String studentCourseDetail = '/courses/:identifier/student-detail';
  static const String getLesson = '/courses/:courseId/lessons/:lessonId';
  static const String markLessonComplete = '/enrollments/:courseId/lessons/:lessonId/complete';
  static const String enrollments = '/enrollments';
  
  // Quizzes
  static const String startQuizAttempt = '/quizzes/:quizId/attempts';
  static const String getQuizQuestions = '/quizzes/:quizId/student-view';
  static const String submitQuizAttempt = '/quizzes/attempts/:attemptId/submit';
  static const String getQuizResult = '/quizzes/attempts/:attemptId';
  
  static const String courseOptions = '/courses/options';
  static const String bulkEnrollment = '/enrollments/bulk';

  // Quizzes
  static const String quizAttempts = '/quizzes/my-attempts';

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
