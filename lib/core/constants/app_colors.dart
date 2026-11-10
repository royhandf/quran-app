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
  static const Color error = Color(0xFFCF6679);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Palet baru (tujuan akhir) - dipakai layar hasil redesign, mulai dari home
  static const Color forest = Color(0xFF1F4D3A);
  static const Color sage = Color(0xFF6B9A74);
  static const Color sageLight = Color(0xFFE6EEE4);
  static const Color sageContainer = Color(0xFFD5E3D3);
  static const Color cream = Color(0xFFF7F6F1);
  static const Color gold = Color(0xFFD9A441);
  static const Color ink = Color(0xFF17251E);
  static const Color inkSecondary = Color(0xFF5E6E64);
  static const Color danger = Color(0xFFB3402F);

  // Palet baru (dark) - varian gelap untuk layar hasil redesign
  static const Color darkHomeBackground = Color(0xFF0D0F0C);
  static const Color darkHomeSurface = Color(0xFF171B17);
  static const Color darkHomePrimaryCard = Color(0xFF2E5B45);
  static const Color darkHomeStarContainer = Color(0xFF252F26);
  static const Color darkHomeInk = Color(0xFFE8EDE8);
  static const Color darkHomeInkSecondary = Color(0xFF9BA79E);
  static const Color darkDanger = Color(0xFFE07A6E);

  // Helper palet baru (mengikuti brightness tema)
  static bool _homeIsDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color homeBackground(BuildContext context) =>
      _homeIsDark(context) ? darkHomeBackground : cream;

  /// Permukaan sekunder: banner penanda + kartu menu sekunder
  static Color homeSurface(BuildContext context) =>
      _homeIsDark(context) ? darkHomeSurface : sageLight;

  /// Latar kartu menu primary
  static Color homePrimarySurface(BuildContext context) =>
      _homeIsDark(context) ? darkHomePrimaryCard : forest;

  /// Wadah ikon bintang pada kartu sekunder
  static Color homeStarSecondary(BuildContext context) =>
      _homeIsDark(context) ? darkHomeStarContainer : sageContainer;

  static Color homeInk(BuildContext context) =>
      _homeIsDark(context) ? darkHomeInk : ink;

  static Color homeInkSecondary(BuildContext context) =>
      _homeIsDark(context) ? darkHomeInkSecondary : inkSecondary;

  /// Warna teks Arab sekunder: forest di light, sageLight di dark
  static Color homeArabicSecondary(BuildContext context) =>
      _homeIsDark(context) ? sageLight : forest;

  /// Aksen emas banner di dark mode; forest di light mode
  static Color homeBannerAccent(BuildContext context) =>
      _homeIsDark(context) ? gold : forest;

  /// Garis pemisah tipis di dalam kartu pengaturan
  static Color homeDivider(BuildContext context) => _homeIsDark(context)
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.06);

  /// Latar bottom sheet: putih di light, surface gelap di dark
  static Color homeSheetSurface(BuildContext context) =>
      _homeIsDark(context) ? darkHomeSurface : Colors.white;

  /// Latar opsi/preview yang tidak terpilih di atas sheet
  static Color homeOptionSurface(BuildContext context) =>
      _homeIsDark(context) ? darkHomeStarContainer : sageLight;

  /// Warna aksi destruktif (hapus): merah redup per mode
  static Color homeDanger(BuildContext context) =>
      _homeIsDark(context) ? darkDanger : danger;

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
