import 'package:feedback/feedback.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:self_finance/providers/app_dir_provider.dart';
import 'package:self_finance/self_finance.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDir = await getApplicationDocumentsDirectory();
  runApp(BetterFeedback(
      child: ProviderScope(
    overrides: [
      appDirProvider.overrideWithValue(appDir.path),
    ],
    child: const SelfFinance(),
  )));
}
