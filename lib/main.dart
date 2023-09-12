import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/views/terms_and_conditions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) => MaterialApp(
        title: 'Self Finance',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: "hell",
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
            backgroundColor: getBackgroundColor,
            accentColor: getPrimaryColor,
            cardColor: getPrimaryColor,
            brightness: Brightness.light,
            errorColor: getErrorColor,
          ),
          useMaterial3: true,
        ),
        home: const TermsAndConditons(),
      ),
    );
  }
}
