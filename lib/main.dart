import 'dart:async';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/backend/user_db.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/self_finance.dart';

void main() async {
  // ensuring all the plugins are connected to the system before running the code
  WidgetsFlutterBinding.ensureInitialized();
  if (Constant.ads) {
    unawaited(
      MobileAds.instance.initialize(),
    );
  }
  await UserBackEnd.db();
  await BackEnd.db();
  runApp(
    const ProviderScope(
      child: BetterFeedback(
       child: SelfFinance(),
      ),
    ),
  );
}
