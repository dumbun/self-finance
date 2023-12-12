import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/providers/p.dart';
import 'package:self_finance/providers/user_backend_provider.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/views/Add%20New%20Entry/add_new_entry_view.dart';
import 'package:self_finance/views/auth_view.dart';
import 'package:self_finance/views/terms_and_conditions.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    ref.watch(backendProvider.notifier).update();
    final ThemeData darkTheme = ThemeData(
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
    final ThemeData lightTheme = ThemeData(
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
    return ResponsiveSizer(
      builder: (context, orientation, screenType) => MaterialApp(
        routes: {
          '/addNewEntry': (context) => const AddNewEntryView(),
        },
        color: AppColors.getPrimaryColor,
        title: 'Self Finance',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeAnimationCurve: Curves.easeInOut,
        home: ref.watch(userDataProvider).when(
              data: (List user) {
                if (user.isNotEmpty) {
                  // if(user) then build AuthView for autontication
                  return AuthView(
                    user: user[0],
                  );
                } else {
                  return const TermsAndConditons();
                }
              },
              loading: () => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
              error: (error, stackTrace) => const Center(
                child: Text('Error fetching user data'),
              ), // Show an error message if fetching fails
            ),
      ),
    );
  }
}
