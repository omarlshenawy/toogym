class AppConstants {
  AppConstants._();

  // ------------------------------------------------------------
  // App
  // ------------------------------------------------------------

  static const String appName = 'GymFlow Pro';

  // ------------------------------------------------------------
  // API
  // ------------------------------------------------------------

  // Change this to your FastAPI server.
  //
  // Local development:
  // http://localhost:8000
  //
  // Production:
  // https://your-api-domain.com
  static const String apiBaseUrl = 'https://gym-saas-connected.onrender.com';

  static const String apiPrefix = '/api/v1';

  // ------------------------------------------------------------
  // Storage keys
  // ------------------------------------------------------------

  static const String accessTokenKey = 'access_token';
  static const String userKey = 'current_user';

  // ------------------------------------------------------------
  // Pagination
  // ------------------------------------------------------------

  static const int defaultPageSize = 20;

  // ------------------------------------------------------------
  // Responsive breakpoints
  // ------------------------------------------------------------

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1200;
}