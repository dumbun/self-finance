import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/fonts/title_widget.dart';
import 'package:self_finance/l10n/app_localizations.dart';
import 'package:self_finance/views/EMI Calculator/emi_calculator_view.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: EMICalculatorView(),
        ),
      ),
    );
  }

  group('EMICalculatorView typography and functionality tests', () {
    testWidgets('renders all typography widgets from lib/core/fonts', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify empty state is displayed with standard font widgets
      expect(
        find.widgetWithText(BodyTwoDefaultText, 'Ready to Calculate'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(
          BodySmallText,
          'Enter a principal amount and interest rate above to view instant payment breakdown and tenure schedule.',
        ),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(BodyTwoDefaultText, 'Loan Principal Amount'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(BodySmallText, 'Monthly Interest Rate (% per month)'),
        findsOneWidget,
      );
    });

    testWidgets('tapping Demo button populates fields and renders results', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap Demo action in header
      final demoFinder = find.widgetWithText(BodySmallText, 'Demo');
      expect(demoFinder, findsOneWidget);
      await tester.tap(demoFinder);
      await tester.pumpAndSettle();

      // Verify results hero card rendered with fonts from lib/core/fonts
      expect(
        find.widgetWithText(BodySmallText, 'TOTAL REPAYMENT AMOUNT'),
        findsOneWidget,
      );
      expect(find.byType(TitleWidget), findsOneWidget);
      expect(
        find.widgetWithText(BodyTwoDefaultText, 'Copy Summary'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(BodyTwoDefaultText, 'Share'),
        findsOneWidget,
      );
    });

    testWidgets('toggling Simple and Compound interest mode updates tags', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap Demo to get calculated state
      await tester.tap(find.widgetWithText(BodySmallText, 'Demo'));
      await tester.pumpAndSettle();

      // Initially Simple mode is selected
      expect(
        find.widgetWithText(BodySmallText, 'SIMPLE'),
        findsOneWidget,
      );

      // Tap Compound Interest mode
      final compoundModeFinder = find.widgetWithText(
        BodySmallText,
        'Compound Interest',
      );
      expect(compoundModeFinder, findsOneWidget);
      await tester.tap(compoundModeFinder);
      await tester.pumpAndSettle();

      // Verify badge updated to COMPOUND
      expect(
        find.widgetWithText(BodySmallText, 'COMPOUND'),
        findsOneWidget,
      );
    });
  });
}
