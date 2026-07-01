import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_alert/core/router/app_router.dart';
import 'package:urban_alert/core/theme/app_theme.dart';

class UrbanAlertApp extends ConsumerWidget {
  const UrbanAlertApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'UrbanAlert',
      debugShowCheckedModeBanner: false,

      // ── Themes ────────────────────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // ── Router ────────────────────────────────────────────────────────────
      routerConfig: router,
    );
  }
}
