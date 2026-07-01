import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_alert/core/providers/core_providers.dart';
import 'package:urban_alert/core/router/route_names.dart';
import 'package:urban_alert/features/auth/presentation/screens/login_screen.dart';
import 'package:urban_alert/features/auth/presentation/screens/register_screen.dart';
import 'package:urban_alert/features/auth/presentation/screens/splash_screen.dart';
import 'package:urban_alert/features/auth/presentation/screens/verify_phone_screen.dart';
import 'package:urban_alert/features/feed/presentation/screens/feed_screen.dart';
import 'package:urban_alert/features/my_alerts/presentation/screens/my_alerts_screen.dart';
import 'package:urban_alert/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:urban_alert/features/shell/presentation/widgets/app_shell.dart';
import 'package:urban_alert/features/suivi/presentation/screens/suivi_screen.dart';

Page<void> _fadePage(Widget child) => CustomTransitionPage<void>(
      child: child,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthChangeNotifier();
  ref.listen(isAuthenticatedProvider, (prev, next) => authNotifier.notify());

  return GoRouter(
    debugLogDiagnostics: false,
    refreshListenable: authNotifier,
    initialLocation: RouteNames.splash,
    redirect: (context, state) async {
      final isAuth = await ref.read(isAuthenticatedProvider.future);
      final location = state.uri.path;

      const authRoutes = {RouteNames.login, RouteNames.register, RouteNames.verifyPhone};
      final isOnAuthRoute = authRoutes.contains(location);
      final isOnSplash = location == RouteNames.splash;

      // SplashScreen handles its own redirect after async init.
      if (isOnSplash) return null;

      if (!isAuth && !isOnAuthRoute) return RouteNames.login;
      if (isAuth && isOnAuthRoute) return RouteNames.feed;
      return null;
    },
    routes: [
      // ── Splash ─────────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splashName,
        pageBuilder: (context, state) => _fadePage(const SplashScreen()),
      ),

      // ── Auth ───────────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.loginName,
        pageBuilder: (context, state) => _fadePage(const LoginScreen()),
      ),
      GoRoute(
        path: RouteNames.register,
        name: RouteNames.registerName,
        pageBuilder: (context, state) => _fadePage(const RegisterScreen()),
      ),
      GoRoute(
        path: RouteNames.verifyPhone,
        name: RouteNames.verifyPhoneName,
        pageBuilder: (_, state) {
          final phone = state.extra as String? ?? '';
          return _fadePage(VerifyPhoneScreen(normalizedPhone: phone));
        },
      ),

      // ── Shell (bottom nav) ─────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          // Feed tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.feed,
                name: RouteNames.feedName,
                builder: (context, state) => const FeedScreen(),
              ),
            ],
          ),

          // Mes signalements tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.myAlerts,
                name: RouteNames.myAlertsName,
                builder: (context, state) => const MyAlertsScreen(),
              ),
            ],
          ),

          // Suivi tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.suivi,
                name: RouteNames.suiviName,
                builder: (context, state) => const SuiviScreen(),
              ),
            ],
          ),

          // Notifications tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.notifications,
                name: RouteNames.notificationsName,
                builder: (context, state) => const NotificationsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page introuvable : ${state.uri}')),
    ),
  );
});

class _AuthChangeNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
