import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';

/// [AppVersionWidget]
/// Shows the version of the application.
/// ex: "App version: 1.1.1+2".
/// This code taken from (https://www.geeksforgeeks.org/flutter-how-to-get-app-name-package-name-version-build-number/)

class AppVersionWidget extends StatefulWidget {
  const AppVersionWidget({super.key});

  @override
  State<AppVersionWidget> createState() => _AppVersionWidgetState();
}

class _AppVersionWidgetState extends State<AppVersionWidget> {
  String? version;
  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo value) {
      version = ("${value.version}+${value.buildNumber}").toString();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BodySmallText(
        italic: true,
        textAlign: TextAlign.center,
        text: 'App version: $version\nINDIA ❤️',
        color: AppColors.getLigthGreyColor,
      ),
    );
  }
}
