import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/backend/user_db.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/theme/theme_data.dart';
import 'package:self_finance/views/Add%20New%20Entry/add_new_entry_view.dart';
import 'package:self_finance/views/auth_view.dart';
import 'package:self_finance/views/terms_and_conditions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserBackEnd.db();
  await BackEnd.db();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) => MaterialApp(
        routes: {
          '/addNewEntry': (context) => const AddNewEntery(),
        },
        color: AppColors.getPrimaryColor,
        title: 'Self Finance',
        debugShowCheckedModeBanner: false,
        theme: AppThemeData.lightTheme,
        darkTheme: AppThemeData.darkTheme,
        themeAnimationCurve: Curves.easeInOut,
        home: ref.watch(asyncUserProvider).when(
              data: (user) {
                if (user.isNotEmpty) {
                  // if user is present then build AuthView for autontication
                  return AuthView(user: user.first);
                } else {
                  // if user is not present then build AuthView for autontication
                  return const TermsAndConditons();
                }
              },
              // in loding state
              loading: () => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
              //if any error happens
              error: (error, stackTrace) => const Scaffold(
                body: Center(
                  child: BodyOneDefaultText(text: 'Error fetching user data'),
                ),
              ),
            ),
      ),
    );
  }
}
