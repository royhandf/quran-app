import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Token desain untuk layar hasil redesign (mulai dari home).
/// Warna ada di [AppColors] - satu-satunya rumah warna, termasuk varian
/// dark via helper `home*` yang theme-aware.
/// Gaya yang dipakai lintas layar naik jadi shared; yang khusus
/// dikelompokkan dengan komentar section per layar.
class AppTokens {
  AppTokens._();

  // Dimensi
  static const double cardRadius = 20;
  static const double buttonRadius = 12;
  static const double pageMargin = 20;
  static const double itemGap = 12;

  // Teks Latin (Poppins) - warna mengikuti tema
  static TextStyle greeting(BuildContext context) => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.homeInkSecondary(context),
  );

  static TextStyle cardLabel(BuildContext context) => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.homeInkSecondary(context),
  );

  static TextStyle bannerTitle(BuildContext context) => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.homeInk(context),
  );

  static TextStyle menuLabel(BuildContext context) => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.homeInk(context),
  );

  // Teks di dalam kartu sholat - latar forest di light maupun dark,
  // jadi tetap putih dan const.
  static const TextStyle prayerCity = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static const TextStyle prayerName = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle prayerTime = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle prayerTimezone = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.gold,
  );

  static const TextStyle prayerChip = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle hijriDate = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // Teks Arab (Amiri)
  static TextStyle bismillah(BuildContext context) => TextStyle(
    fontFamily: 'Amiri',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.homeInk(context),
  );

  static TextStyle menuArabic(BuildContext context, double fontSize) =>
      TextStyle(
        fontFamily: 'Amiri',
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: AppColors.homeArabicSecondary(context),
      );

  static const TextStyle prayerArabic = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );
}
