import 'package:flutter/material.dart';

/// Token desain halaman home (ref-home.png).
/// Satu-satunya sumber warna, radius, spacing, dan gaya teks home —
/// jangan hardcode nilai ini lagi di widget.
class AppTokens {
  AppTokens._();

  // ── Warna ──
  static const Color forest = Color(0xFF1F4D3A);
  static const Color sage = Color(0xFF6B9A74);
  static const Color sageLight = Color(0xFFE6EEE4);
  static const Color sageContainer = Color(0xFFD5E3D3);
  static const Color cream = Color(0xFFF7F6F1);
  static const Color gold = Color(0xFFD9A441);
  static const Color ink = Color(0xFF17251E);
  static const Color inkSecondary = Color(0xFF5E6E64);

  // ── Dimensi ──
  static const double cardRadius = 20;
  static const double buttonRadius = 12;
  static const double pageMargin = 20;
  static const double itemGap = 12;

  // ── Teks Latin (Manrope) ──
  static const TextStyle greeting = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: inkSecondary,
  );

  static const TextStyle cardLabel = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: inkSecondary,
  );

  static const TextStyle bannerTitle = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: ink,
  );

  static const TextStyle menuLabel = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: ink,
  );

  static const TextStyle prayerCity = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static const TextStyle prayerLabel = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    color: Color(0xB3FFFFFF),
  );

  static const TextStyle prayerName = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle prayerTime = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle prayerTimezone = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: gold,
  );

  static const TextStyle prayerChip = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // ── Teks Arab (Amiri) ──
  static const TextStyle bismillah = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: forest,
  );

  static const TextStyle hijriDate = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static TextStyle menuArabic(double fontSize) => TextStyle(
    fontFamily: 'Amiri',
    fontSize: fontSize,
    fontWeight: FontWeight.w400,
    color: forest,
  );

  static const TextStyle prayerArabic = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );
}
