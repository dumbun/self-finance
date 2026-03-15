import 'package:flutter/material.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/utility/user_utility.dart';

class AppVersionWidget extends StatelessWidget {
  const AppVersionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: Utility.getAppVersion(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState case ConnectionState.waiting) {
          return const BodyTwoDefaultText(text: 'Loading....');
        } else {
          if (snapshot.hasError) {
            return BodyTwoDefaultText(text: 'Error: ${snapshot.error}');
          } else {
            return BodyTwoDefaultText(text: 'Version: ${snapshot.data}');
          }
        }
      },
    );
  }
}
