import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/providers/settings_provider.dart';
import 'package:self_finance/views/Add%20New%20Entry/customer_details_entry_view.dart';
import 'package:self_finance/views/account_setting_view.dart';
import 'package:self_finance/views/auth_view.dart';
import 'package:self_finance/views/contacts_view.dart';
import 'package:self_finance/views/dashboard_view.dart';

class SelfFinance extends ConsumerWidget {
  const SelfFinance({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(themeProvider)
        .when(
          data: (bool data) {
            return ResponsiveSizer(
              key: UniqueKey(),
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
                      useMaterial3: true,
                      fontFamily: Constant.appFont,
                      primaryColor: AppColors.getPrimaryColor,
                      cardTheme: const CardThemeData(elevation: 2),
                      primarySwatch: Colors.blue,
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: AppColors.getPrimaryColor,
                        error: AppColors.getErrorColor,
                        brightness: Brightness.light,
                        primary: AppColors.getPrimaryColor,
                        onPrimary: Colors.white,
                      ),
                      brightness: Brightness.light,
                    ),
                    darkTheme: ThemeData(
                      primaryColor: AppColors.getPrimaryColor,
                      cardTheme: const CardThemeData(elevation: 2),
                      brightness: Brightness.dark,
                      scaffoldBackgroundColor: AppColors.getPrimaryTextColor,
                      navigationBarTheme: const NavigationBarThemeData(
                        backgroundColor: AppColors.getPrimaryTextColor,
                      ),
                      fontFamily: Constant.appFont,
                      primarySwatch: Colors.blue,
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: AppColors.getPrimaryColor,
                        error: AppColors.getErrorColor,
                        brightness: Brightness.dark,
                        primary: AppColors.getPrimaryColor,
                        onPrimary: Colors.white,
                      ),
                    ),
                    themeAnimationCurve: Curves.easeInOut,
                    themeMode: data ? ThemeMode.dark : ThemeMode.light,
                    home: const AuthView(),
                  ),
            );
          },
          error: (_, _) => const MaterialApp(
            home: Scaffold(
              body: Center(
                child: BodyTwoDefaultText(
                  text: "Error happend! Please restart the application",
                ),
              ),
            ),
          ),
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
        );
  }
}
