import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography scale and Material ThemeData for ColorFlow: Sort Master.
class AppTypography {
  AppTypography._();

  static TextStyle get headlineXl => GoogleFonts.plusJakartaSans(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        height: 40 / 34,
        letterSpacing: -0.5,
        color: AppColors.darkText,
      );

  static TextStyle get headlineLg => GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 32 / 26,
        color: AppColors.darkText,
      );

  static TextStyle get headlineMd => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 26 / 20,
        color: AppColors.darkText,
      );

  static TextStyle get bodyLg => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 22 / 16,
        color: AppColors.darkText,
      );

  static TextStyle get bodyMd => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        color: AppColors.darkText,
      );

  static TextStyle get labelLg => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 18 / 15,
        color: AppColors.darkText,
      );

  static TextStyle get labelMd => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 16 / 13,
        color: AppColors.darkText,
      );

  static TextStyle get labelSm => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 14 / 11,
        color: AppColors.darkText,
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.deepViolet,
          brightness: Brightness.light,
          surface: AppColors.canvas,
        ),
        textTheme: GoogleFonts.nunitoTextTheme().apply(
          bodyColor: AppColors.darkText,
          displayColor: AppColors.darkText,
        ),
      );
}
