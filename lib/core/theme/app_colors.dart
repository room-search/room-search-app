import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color seed = Color(0xFF7C5CFF);

  // Light
  static const Color primaryLight = Color(0xFF7C5CFF);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color secondaryLight = Color(0xFFFFB4A2);
  static const Color tertiaryLight = Color(0xFF65D6AD);
  static const Color surfaceLight = Color(0xFFFBFAFF);
  static const Color onSurfaceLight = Color(0xFF1B1930);
  static const Color surfaceContainerLight = Color(0xFFF2F0FA);
  static const Color backgroundLight = Color(0xFFF5F4FA);
  static const Color errorLight = Color(0xFFE5484D);
  static const Color outlineLight = Color(0xFFE1DEF2);

  // Dark
  static const Color primaryDark = Color(0xFFA89AFF);
  static const Color onPrimaryDark = Color(0xFF1B1233);
  static const Color secondaryDark = Color(0xFFFFB59E);
  static const Color tertiaryDark = Color(0xFF74E0B9);
  static const Color surfaceDark = Color(0xFF14121F);
  static const Color onSurfaceDark = Color(0xFFECEAF5);
  static const Color surfaceContainerDark = Color(0xFF1E1B2D);
  static const Color backgroundDark = Color(0xFF0E0C17);
  static const Color errorDark = Color(0xFFFF6B70);
  static const Color outlineDark = Color(0xFF2F2A44);

  // Score scale (radar, bars) — consistent across themes
  static const Color scoreLow = Color(0xFF65D6AD);
  static const Color scoreMid = Color(0xFFFFB547);
  static const Color scoreHigh = Color(0xFFE5484D);
}
