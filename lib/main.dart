import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/backend/user_database.dart';
import 'package:feedback/feedback.dart';
import 'package:self_finance/core/utility/notification_service.dart';
import 'package:self_finance/self_finance.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserBackEnd.db();
  await dotenv.load(fileName: ".env");
  await NotificationService().initNotification();
  runApp(const ProviderScope(child: BetterFeedback(child: SelfFinance())));
}
