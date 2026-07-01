abstract final class ApiConstants {
  // Change to your machine's local IP when testing on a physical device
  static const String _baseHost = 'localhost:8080';
  static const String baseUrl = 'http://$_baseHost/api';
  static const String wsUrl = 'http://$_baseHost/ws';

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String login = '/v1/auth/login';
  static const String register = '/v1/auth/register';
  static const String verifyPhone = '/v1/auth/verify-phone';
  static const String resendOtp = '/v1/auth/resend-otp';

  // ── Alerts ───────────────────────────────────────────────────────────────
  static const String alerts = '/v1/alerts';
  static const String alertsSearch = '/v1/alerts/search';
  static String alertById(int id) => '/v1/alerts/$id';
  static String alertImages(int id) => '/v1/alerts/$id/images';
  static String alertVideos(int id) => '/v1/alerts/$id/videos';
  static const String myAlerts = '/v1/alerts/user/my-alerts';

  // ── Problem types (categories) ───────────────────────────────────────────
  static const String problemTypes = '/v1/problem-types';

  // ── Problems (signalements groupés) ─────────────────────────────────────
  static const String problems = '/v1/problems';
  static const String myAlertProblems = '/v1/problems/user/my-alert-problems';
  static String problemById(int id) => '/v1/problems/$id';

  // ── Notifications ────────────────────────────────────────────────────────
  static const String notifications = '/v1/notifications';
  static const String notificationsUnreadCount = '/v1/notifications/unread-count';
  static const String notificationsReadAll = '/v1/notifications/read-all';
  static String notificationMarkRead(int id) => '/v1/notifications/$id/read';

  // ── Cloudinary ───────────────────────────────────────────────────────────
  static const String cloudName = 'daacpbysm';
  static const String cloudinaryUploadPreset = 'urabnAlert';
  static String cloudinaryUploadUrl(String resourceType) =>
      'https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload';

  // ── Misc ─────────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const String tokenKey = 'jwt_token';
}
