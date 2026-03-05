import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0F9B8E);
  static const Color primaryLight = Color(0xFF14C4B0);
  static const Color primaryDark = Color(0xFF0A7B70);

  // Light
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightAppBar = Color(0xFFFFFFFF);

  // Dark
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF252525);
  static const Color darkTextPrimary = Color(0xFFE8E8E8);
  static const Color darkTextSecondary = Color(0xFFA0A0A0);
  static const Color darkDivider = Color(0xFF2C2C2C);
  static const Color darkAppBar = Color(0xFF1E1E1E);

  // Common
  static const Color gold = Color(0xFFD4AF37);
  static const Color error = Color(0xFFCF6679);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Context-aware helpers
  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkBackground
      : lightBackground;
  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkSurface
      : lightSurface;
  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCard : lightCard;
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkTextPrimary
      : lightTextPrimary;
  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkTextSecondary
      : lightTextSecondary;
  static Color dividerColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkDivider
      : lightDivider;
  static Color appBarColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkAppBar
      : lightAppBar;
}
