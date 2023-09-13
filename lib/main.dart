import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/user_db.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/views/dashboard_view.dart';
import 'package:self_finance/views/terms_and_conditions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoadind = true;
  User? user;
  fetchData() async {
    setState(() {
      _isLoadind = true;
    });
    final result = await UserBackEnd.fetchUserData();
    if (result != null) {
      setState(() {
        user = result;
      });
    }
    if (result == null) {
      setState(() {
        user = null;
      });
    }
    setState(() {
      _isLoadind = false;
    });
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

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
        home: _isLoadind
            ? const Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : user == null
                ? const TermsAndConditons()
                : Dashboard(
                    user: user!,
                  ),
      ),
    );
  }
}
