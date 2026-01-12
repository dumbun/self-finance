import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/views/Add%20New%20Entry/customer_details_entry_view.dart';
import 'package:self_finance/views/account_setting_view.dart';
import 'package:self_finance/views/auth_view.dart';
import 'package:self_finance/views/contacts_view.dart';
import 'package:self_finance/views/dashboard_view.dart';

class SelfFinance extends StatelessWidget {
  const SelfFinance({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder:
          (
            BuildContext context,
            Orientation orientation,
            ScreenType screenType,
          ) => MaterialApp(
            routes: {
              Constant.dashboardView: (BuildContext context) =>
                  const DashboardView(),
              Constant.addNewEntryView: (BuildContext context) =>
                  const CustomerDetailsEntryView(),
              Constant.contactView: (BuildContext context) =>
                  const ContactsView(),
              Constant.accountSettingsView: (BuildContext context) =>
                  const AccountSettingsView(),
            },
            color: AppColors.getPrimaryColor,
            title: Constant.appTitle,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              primaryColor: AppColors.getPrimaryColor,
              cardTheme: CardThemeData(
                color: AppColors.getBackgroundColor,
                elevation: 0,
              ),
              fontFamily: Constant.appFont,
              appBarTheme: const AppBarTheme(elevation: 0),
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.getPrimaryColor,
                error: AppColors.getErrorColor,
                surface: AppColors.getVeryLightGreyColor,
                primary: AppColors.getPrimaryColor,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              fontFamily: Constant.appFont,
              useMaterial3: true,
              primaryColor: AppColors.getPrimaryColor,
              primaryColorDark: AppColors.getPrimaryTextColor,
              primarySwatch: Colors.blue,
              appBarTheme: const AppBarTheme(elevation: 0),
              colorScheme: ColorScheme.fromSeed(
                surface: AppColors.getPrimaryTextColor,
                error: AppColors.getErrorColor,
                seedColor: AppColors.getPrimaryColor,
                primary: AppColors.getPrimaryColor,
                brightness: Brightness.dark,
              ),
            ),
            themeAnimationCurve: Curves.easeInOut,
            home: const AuthView(),
          ),
    );
  }
}
