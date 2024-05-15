import 'package:flutter/material.dart';
import 'package:self_finance/theme/app_colors.dart';

class AppThemeData {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: AppColors.getPrimaryColor,
    cardTheme: const CardTheme(color: AppColors.getBackgroundColor, elevation: 0),
    fontFamily: "hell",
    appBarTheme: const AppBarTheme(
      elevation: 0,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.getPrimaryColor,
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
    useMaterial3: true,
    primaryColor: AppColors.getPrimaryColor,
    primaryColorDark: AppColors.getPrimaryTextColor,
    primarySwatch: Colors.blue,
    appBarTheme: const AppBarTheme(
      elevation: 0,
    ),
    colorScheme: ColorScheme.fromSeed(
      surface: AppColors.getPrimaryTextColor,
      error: AppColors.getErrorColor,
      seedColor: AppColors.getPrimaryColor,
      primary: AppColors.getPrimaryColor,
      brightness: Brightness.dark,
    ),
  );
}
