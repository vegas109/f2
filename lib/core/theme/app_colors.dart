import 'package:flutter/material.dart';

/// Central color palette for CodeHero.
///
/// The overall look is clean, modern and minimal (not neon/cyberpunk):
/// a soft dark surface with a single confident accent, plus two
/// language-specific accents used sparingly to distinguish tracks.
class AppColors {
  AppColors._();

  // Brand accent (calm violet — used for primary actions).
  static const Color primary = Color(0xFF7C5CFF);
  static const Color primaryDark = Color(0xFF5B3FE0);

  // Language track accents.
  static const Color python = Color(0xFFFFC93C); // warm amber
  static const Color cpp = Color(0xFF3DA9FC); // cool blue

  // Dark surfaces.
  static const Color background = Color(0xFF0E0F13);
  static const Color surface = Color(0xFF171922);
  static const Color surfaceHigh = Color(0xFF1F222E);
  static const Color outline = Color(0xFF2A2E3C);

  // Text.
  static const Color textPrimary = Color(0xFFF4F5F7);
  static const Color textSecondary = Color(0xFFA7ACBA);
  static const Color textMuted = Color(0xFF6C7180);

  // Semantic.
  static const Color success = Color(0xFF3ED598);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = Color(0xFFFF5C5C);
  static const Color energy = Color(0xFFFF5C7A); // hearts / energy
  static const Color crystal = Color(0xFF4FD1FF); // premium currency

  /// Returns the accent color for a given language track id ("python"/"cpp").
  static Color track(String languageId) =>
      languageId == 'cpp' ? cpp : python;
}
