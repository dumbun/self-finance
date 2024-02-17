import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/backend/user_db.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/theme/app_theme_data.dart';
import 'package:self_finance/views/Add%20New%20Entry/add_new_entry_view.dart';
import 'package:self_finance/views/auth_view.dart';
import 'package:self_finance/views/change_pin_view.dart';
import 'package:self_finance/views/contacts_view.dart';
import 'package:self_finance/views/dashboard_view.dart';
import 'package:self_finance/views/account_setting_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserBackEnd.db();
  await BackEnd.db();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) => MaterialApp(
        routes: {
          Constant.changePinView: (context) => const ChangePinView(),
          Constant.dashboardView: (context) => const DashboardView(),
          Constant.addNewEntryView: (context) => const AddNewEntery(),
          Constant.contactView: (context) => const ContactsView(),
          Constant.accountSettingsView: (context) => const AccountSettingsView(),
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
