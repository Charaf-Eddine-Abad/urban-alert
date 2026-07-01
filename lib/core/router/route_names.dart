/// Single source of truth for route paths and names.
/// Using constants prevents typos and makes refactoring safe.
abstract final class RouteNames {
  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyPhone = '/verify-phone';

  // ── Shell (bottom nav) ───────────────────────────────────────────────────
  static const String shell = '/app';
  static const String feed = '/app/feed';
  static const String myAlerts = '/app/my-alerts';
  static const String suivi = '/app/suivi';
  static const String notifications = '/app/notifications';

  // ── Detail routes (pushed on top of shell) ───────────────────────────────
  static const String alertDetail = '/app/alerts/:id';
  static const String problemDetail = '/app/problems/:id';
  static const String createAlert = '/app/my-alerts/create';
  static const String editAlert = '/app/my-alerts/:id/edit';

  // ── Named route identifiers ───────────────────────────────────────────────
  static const String splashName = 'splash';
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String verifyPhoneName = 'verifyPhone';
  static const String feedName = 'feed';
  static const String myAlertsName = 'myAlerts';
  static const String suiviName = 'suivi';
  static const String notificationsName = 'notifications';
  static const String alertDetailName = 'alertDetail';
  static const String problemDetailName = 'problemDetail';
  static const String createAlertName = 'createAlert';
  static const String editAlertName = 'editAlert';
}
