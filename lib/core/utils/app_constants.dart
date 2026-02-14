class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'LMS Rise and Impact';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 20;

  // Timeouts
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';

  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm:ss';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int otpLength = 6;
}
