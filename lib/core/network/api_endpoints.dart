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
  static const String updateProfile = '/users/update';

  // Courses
  static const String getCourses = '/courses';
  static const String bulkEnrollment = '/enrollments/bulk';
}
