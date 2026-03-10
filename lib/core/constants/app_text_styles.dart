import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle headingLarge(BuildContext context) => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary(context),
  );

  static TextStyle headingMedium(BuildContext context) => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary(context),
  );

  static TextStyle headingSmall(BuildContext context) => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary(context),
  );

  static TextStyle bodyLarge(BuildContext context) =>
      GoogleFonts.poppins(fontSize: 16, color: AppColors.textPrimary(context));

  static TextStyle bodyMedium(BuildContext context) =>
      GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary(context));

  static TextStyle bodySmall(BuildContext context) => GoogleFonts.poppins(
    fontSize: 12,
    color: AppColors.textSecondary(context),
  );

  static TextStyle arabicLarge(
    BuildContext context, {
    double? fontSize,
    String fontType = 'Uthmani',
  }) => TextStyle(
    fontFamily: fontType == 'IndoPak' ? 'Lateef' : 'ScheherazadeNew',
    fontSize: fontSize ?? 28,
    height: 2.0,
    color: AppColors.textPrimary(context),
  );

  static TextStyle arabicMedium(
    BuildContext context, {
    double? fontSize,
    String fontType = 'Uthmani',
  }) => TextStyle(
    fontFamily: fontType == 'IndoPak' ? 'Lateef' : 'ScheherazadeNew',
    fontSize: fontSize ?? 22,
    height: 1.8,
    color: AppColors.textPrimary(context),
  );

  static TextStyle sectionHeader(BuildContext context) => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: 0.5,
  );

  static TextStyle menuButton() => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: 2.0,
  );
}
