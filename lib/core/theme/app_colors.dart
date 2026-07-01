import 'package:flutter/material.dart';

/// Brand colours — reference these instead of hardcoding hex values.
/// The Material 3 [ColorScheme] is generated from [seedColor] in [AppTheme];
/// only use these constants for custom surfaces not covered by the scheme.
abstract final class AppColors {
  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color seedColor = Color(0xFF1A56DB);  // civic blue
  static const Color primary = Color(0xFF1A56DB);
  static const Color primaryDark = Color(0xFF0D47A1);

  // ── Status (shared across light/dark) ─────────────────────────────────────
  static const Color statusNew = Color(0xFF3B82F6);        // blue
  static const Color statusInProgress = Color(0xFFF59E0B); // amber
  static const Color statusResolved = Color(0xFF10B981);   // emerald
  static const Color statusRejected = Color(0xFFEF4444);   // red

  // ── Priority ──────────────────────────────────────────────────────────────
  static const Color priorityLow = Color(0xFF6B7280);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityHigh = Color(0xFFF97316);
  static const Color priorityCritical = Color(0xFFEF4444);

  // ── Neutral surfaces ──────────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFEEF2F7);

  // ── Shimmer (skeleton loading) ────────────────────────────────────────────
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
