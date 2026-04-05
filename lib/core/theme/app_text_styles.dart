import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _poppins => GoogleFonts.poppins();
  static TextStyle get _dmSans => GoogleFonts.dmSans();

  // Display
  static TextStyle display = _poppins.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    color: AppColors.textDark,
  );

  // Headings
  static TextStyle h1 = _poppins.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: AppColors.textDark,
  );

  static TextStyle h2 = _poppins.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static TextStyle h3 = _poppins.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  // Subtitles
  static TextStyle subtitle1 = _dmSans.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textBody,
  );

  static TextStyle subtitle2 = _dmSans.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  // Body
  static TextStyle body1 = _dmSans.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textBody,
    height: 1.5,
  );

  static TextStyle body2 = _dmSans.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textBody,
    height: 1.5,
  );

  // Labels
  static TextStyle label = _dmSans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall = _dmSans.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    letterSpacing: 0.5,
  );

  // Button
  static TextStyle button = _poppins.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );

  static TextStyle buttonSmall = _poppins.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnPrimary,
  );

  // Caption
  static TextStyle caption = _dmSans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
}
