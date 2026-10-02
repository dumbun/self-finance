import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feedback/feedback.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/self_finance.dart';

Future<void> main() async {
  await Utility.appInit(); // now without the display mode call
  runApp(const BetterFeedback(child: ProviderScope(child: SelfFinance())));
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (Platform.isAndroid) {
      FlutterDisplayMode.setHighRefreshRate();
    }
  });
}
