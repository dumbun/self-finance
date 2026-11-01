import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:self_finance/l10n/app_localizations.dart';
import 'package:self_finance/providers/app_dir_provider.dart';
import 'package:self_finance/views/Add%20New%20Entry/customer_details_entry_view.dart';
import 'package:self_finance/widgets/country_code_picker_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:self_finance/widgets/section_header_widget.dart';
import 'package:self_finance/widgets/signature_widget.dart';

void main() {
  group('CustomerDetailsEntryView Unified & Responsive Layout Tests', () {
    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          appDirProvider.overrideWith((ref) => '/tmp'),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CustomerDetailsEntryView(),
        ),
      );
    }

    testWidgets('renders all section headers, cards, and input fields in a single view', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Check AppBar title & subtitle
      expect(find.text('New Customer & Loan'), findsOneWidget);
      expect(find.text('Enter customer, loan, item and signature details'), findsOneWidget);

      // Check 4 Section Headers
      expect(find.byType(SectionHeaderWidget), findsNWidgets(4));
      expect(find.text('CUSTOMER INFORMATION'), findsOneWidget);
      expect(find.text('LOAN TERMS & INTEREST'), findsOneWidget);
      expect(find.text('COLLATERAL & DOCUMENTATION'), findsOneWidget);
      expect(find.text('BORROWER ACKNOWLEDGEMENT'), findsOneWidget);

      // Check Customer Info fields
      expect(find.text('Customer photo'), findsOneWidget);
      expect(find.text('Customer proof'), findsOneWidget);
      expect(find.text('Customer full name'), findsOneWidget);
      expect(find.text('Guardian full name'), findsOneWidget);
      expect(find.text('Customer mobile number'), findsOneWidget);
      expect(find.text('Customer address'), findsOneWidget);

      // Check Country Code Picker
      expect(find.byType(CountryCodePickerWidget), findsOneWidget);
      expect(find.text('🇮🇳'), findsOneWidget);
      expect(find.text('+91'), findsOneWidget);

      // Scroll to view Loan Terms & Collateral
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      // Check Loan Terms fields
      expect(find.text('Taken amount'), findsOneWidget);
      expect(find.text('Monthly interest rate %'), findsOneWidget);
      expect(find.text('Taken date'), findsOneWidget);

      // Check Collateral & Documentation
      expect(find.text('Item description'), findsOneWidget);
      expect(find.text('Customer item'), findsOneWidget);

      // Scroll to view Signature & Submit
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.byType(SignatureWidget), findsOneWidget);
      expect(find.byType(RoundedCornerButton), findsOneWidget);
      expect(find.text('Create Customer & Loan'), findsOneWidget);
    });

    testWidgets('responsive layout constrains max width to 640 on tablet/desktop viewports', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final constrainedBoxFinder = find.byWidgetPredicate(
        (widget) =>
            widget is ConstrainedBox &&
            widget.constraints.maxWidth == 640,
      );
      expect(constrainedBoxFinder, findsOneWidget);
    });

    testWidgets('validation triggers error on empty required fields', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Scroll until submit button is fully visible and tap it
      final submitButton = find.text('Create Customer & Loan');
      await tester.scrollUntilVisible(
        submitButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Validation errors should be present
      expect(find.text('Please enter a valid value'), findsWidgets);
    });
  });
}
