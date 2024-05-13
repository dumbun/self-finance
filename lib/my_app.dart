import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/theme/app_theme_data.dart';
import 'package:self_finance/views/Add%20New%20Entry/add_new_entry_view.dart';
import 'package:self_finance/views/account_setting_view.dart';
import 'package:self_finance/views/auth_view.dart';
import 'package:self_finance/views/contacts_view.dart';
import 'package:self_finance/views/dashboard_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (BuildContext context, Orientation orientation, ScreenType screenType) => MaterialApp(
        routes: {
          Constant.dashboardView: (BuildContext context) => const DashboardView(),
          Constant.addNewEntryView: (BuildContext context) => const AddNewEntery(),
          Constant.contactView: (BuildContext context) => const ContactsView(),
          Constant.accountSettingsView: (BuildContext context) => const AccountSettingsView(),
        },
        color: AppColors.getPrimaryColor,
        title: Constant.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppThemeData.lightTheme,
        darkTheme: AppThemeData.darkTheme,
        themeAnimationCurve: Curves.easeInOut,
        home: const AuthView(),
      ),
    );
  }
}