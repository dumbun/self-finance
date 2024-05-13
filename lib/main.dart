import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/backend/user_db.dart';
import 'package:self_finance/my_app.dart';

void main() async {
  // ensuring all the plugins are connected to the system before running the code
  WidgetsFlutterBinding.ensureInitialized();
  await UserBackEnd.db();
  await BackEnd.db();

  runApp(
    const ProviderScope(
      child: BetterFeedback(
        child: MyApp(),
      ),
    ),
  );
}
