import 'package:flutter/material.dart';
import 'package:self_finance/theme/colors.dart';

class AppThemeData {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: AppColors.getPrimaryColor,
    cardTheme: const CardTheme(color: AppColors.getVeryLightGreyColor),
    fontFamily: "hell",
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.getPrimaryColor,
      background: AppColors.getBackgroundColor,
      error: AppColors.getErrorColor,
      surface: AppColors.getVeryLightGreyColor,
      primary: AppColors.getPrimaryColor,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: "hell",
    colorScheme: ColorScheme.fromSeed(
      background: AppColors.getPrimaryTextColor,
      error: AppColors.getErrorColor,
      seedColor: AppColors.getPrimaryColor,
      primary: AppColors.getPrimaryColor,
      brightness: Brightness.dark,
    ),
    primarySwatch: Colors.blue,
    useMaterial3: true,
    primaryColor: AppColors.getPrimaryColor,
  );
}
