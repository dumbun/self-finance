import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/self_finance.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BetterFeedback(child: ProviderScope(child: SelfFinance())));
}
