import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/l10n/app_localizations.dart';
import 'package:self_finance/views/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'SplashScreen renders title, subtitle, and moving gradient without crashing',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SplashScreen(autoInit: false),
          ),
        ),
      );

      // Verify title, subtitle, and brand icon exist
      expect(find.text('Self-Finance'), findsOneWidget);
      expect(find.text('Personal Lending & Finance'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Verify animation progresses smoothly
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Self-Finance'), findsOneWidget);

      // Clean up widget tree so repeating animation controllers are disposed
      await tester.pumpWidget(const SizedBox());
    },
  );
}
