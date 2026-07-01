import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Extends the Material 3 [TextTheme] with Poppins.
/// Access via [Theme.of(context).textTheme] — this is applied globally
/// in [AppTheme], so you should never need to call these directly.
abstract final class AppTextStyles {
  static TextTheme get textTheme => GoogleFonts.poppinsTextTheme();

  // ── Convenience styles for one-offs ───────────────────────────────────────

  static TextStyle get displayLarge => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleLarge => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleMedium => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get labelMedium => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      );

  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
      );
}
