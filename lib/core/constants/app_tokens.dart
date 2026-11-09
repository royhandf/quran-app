import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Token desain untuk layar hasil redesign (mulai dari home).
///
/// Strukturnya dua lapis:
/// - Builder dasar (`_latin`, `_arabic`) - satu-satunya tempat font family,
///   size, weight, dan warna disusun.
/// - Token semantik (`pageTitle`, `tileTitle`, dst) - nama berdasarkan
///   peruntukan, disusun dari builder. Mengubah font/ukuran global cukup
///   di satu tempat; token semantik boleh berkembang sendiri nanti.
///
/// Warna ada di [AppColors] - satu-satunya rumah warna, termasuk varian
/// dark via helper `home*` yang theme-aware.
class AppTokens {
  AppTokens._();

  // Font family
  static const String fontLatin = 'Poppins';
  static const String fontArabic = 'Amiri';

  // Dimensi
  static const double cardRadius = 20;
  static const double buttonRadius = 12;
  static const double pageMargin = 20;
  static const double itemGap = 12;
  static const double sheetRadius = 24;

  // ── Builder dasar ──
  static TextStyle _latin(
    double size,
    FontWeight weight,
    Color color, {
    double? letterSpacing,
    List<FontFeature>? fontFeatures,
  }) => TextStyle(
    fontFamily: fontLatin,
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    fontFeatures: fontFeatures,
  );

  static TextStyle _arabic(double size, FontWeight weight, Color color) =>
      TextStyle(
        fontFamily: fontArabic,
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  // ── Teks Latin (Poppins) - warna mengikuti tema ──
  static TextStyle pageTitle(BuildContext context) =>
      _latin(20, FontWeight.w700, AppColors.homeInk(context));

  static TextStyle sheetTitle(BuildContext context) =>
      _latin(17, FontWeight.w700, AppColors.homeInk(context));

  static TextStyle tileTitle(BuildContext context) =>
      _latin(14, FontWeight.w600, AppColors.homeInk(context));

  static TextStyle tileSubtitle(BuildContext context) =>
      _latin(11, FontWeight.w400, AppColors.homeInkSecondary(context));

  static TextStyle tileValue(BuildContext context) =>
      _latin(13, FontWeight.w600, AppColors.homeArabicSecondary(context));

  static TextStyle greeting(BuildContext context) =>
      _latin(14, FontWeight.w500, AppColors.homeInkSecondary(context));

  static TextStyle cardLabel(BuildContext context) => _latin(
    11,
    FontWeight.w700,
    AppColors.homeInkSecondary(context),
    letterSpacing: 1.2,
  );

  static TextStyle bannerTitle(BuildContext context) =>
      _latin(15, FontWeight.w600, AppColors.homeInk(context));

  static TextStyle menuLabel(BuildContext context) =>
      _latin(16, FontWeight.w600, AppColors.homeInk(context));

  // ── Teks Arab (Amiri) - warna mengikuti tema ──
  static TextStyle bismillah(BuildContext context) =>
      _arabic(24, FontWeight.w700, AppColors.homeInk(context));

  static TextStyle menuArabic(BuildContext context, double fontSize) =>
      _arabic(fontSize, FontWeight.w400, AppColors.homeArabicSecondary(context));

  // ── Teks di dalam kartu sholat ──
  // Latar forest sama di light maupun dark, jadi teksnya putih konstan.
  static const TextStyle prayerCity = TextStyle(
    fontFamily: fontLatin,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static const TextStyle prayerName = TextStyle(
    fontFamily: fontLatin,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle prayerTime = TextStyle(
    fontFamily: fontLatin,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle prayerTimezone = TextStyle(
    fontFamily: fontLatin,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.gold,
  );

  static const TextStyle prayerChip = TextStyle(
    fontFamily: fontLatin,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle hijriDate = TextStyle(
    fontFamily: fontLatin,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static const TextStyle prayerArabic = TextStyle(
    fontFamily: fontArabic,
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );
}
