import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart' as native_loc;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/providers/settings_provider.dart';
import 'package:self_finance/views/splash_screen.dart';

class SelfFinance extends ConsumerWidget {
  const SelfFinance({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeProvider);
    final bool darkMode = themeAsync.value ?? false;

    return MaterialApp(
      localizationsDelegates: const [
        native_loc.GlobalMaterialLocalizations.delegate,
        native_loc.GlobalWidgetsLocalizations.delegate,
        native_loc.GlobalCupertinoLocalizations.delegate,
      ],
      routes: Routes.namedRoutes,
      color: AppColors.getPrimaryColor,
      title: Constant.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: Constant.appFont,
        primaryColor: AppColors.getPrimaryColor,
        cardTheme: const CardThemeData(elevation: 2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.getPrimaryColor,
          error: AppColors.getErrorColor,
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.getPrimaryColor,
          error: AppColors.getErrorColor,
          brightness: Brightness.dark,
          primary: AppColors.getPrimaryColor,
          onPrimary: Colors.white,
        ),
      ),
      themeAnimationCurve: Curves.easeInOut,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
