import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/backend_provider.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/views/Add%20New%20Entry/add_new_entry_view.dart';
import 'package:self_finance/views/auth_view.dart';
import 'package:self_finance/views/terms_and_conditions.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      fontFamily: "hell",
      colorScheme: ColorScheme.fromSeed(
        background: getPrimaryTextColor,
        error: getErrorColor,
        seedColor: getPrimaryColor,
        primary: getPrimaryColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      primaryColor: getPrimaryColor,
    );
    ThemeData lightTheme = ThemeData(
      primaryColor: getPrimaryColor,
      cardTheme: const CardTheme(color: getVeryLightGreyColor),
      fontFamily: "hell",
      colorScheme: ColorScheme.fromSeed(
        seedColor: getPrimaryColor,
        background: getBackgroundColor,
        error: getErrorColor,
        surface: getVeryLightGreyColor,
        primary: getPrimaryColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
    return ResponsiveSizer(
      builder: (context, orientation, screenType) => MaterialApp(
        routes: {
          '/addNewEntry': (context) => const AddNewEntryView(),
        },
        color: getPrimaryColor,
        title: 'Self Finance',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeAnimationCurve: Curves.easeInOut,
        home: Consumer(
          builder: (context, ref, child) {
            AsyncValue<User?> userData = ref.watch(userDataProvider);
            return userData.when(
              data: (user) {
                if (user != null) {
                  // if(user) then build AuthView for autontication
                  return AuthView(user: user);
                } else {
                  return const TermsAndConditons();
                }
              },
              loading: () => const Center(
                child: CircularProgressIndicator.adaptive(),
              ), // Show a loader while fetching data
              error: (error, stackTrace) => const Center(
                child: Text('Error fetching user data'),
              ), // Show an error message if fetching fails
            );
          },
        ),
      ),
    );
  }
}
