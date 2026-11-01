import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:self_finance/l10n/app_localizations.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/providers/app_dir_provider.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/views/add_new_transaction_view.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:self_finance/widgets/section_header_widget.dart';

class _FakeCustomerNotifier extends CustomerNotifier {
  _FakeCustomerNotifier(this.customer);
  final Customer? customer;

  @override
  Stream<Customer?> build(String id) => Stream.value(customer);
}

void main() {
  group('AddNewTransactionView UI & Responsive Tests', () {
    const testCustomerId = '01a17237-b6bb-7b79-bf16-e4183a584599';
    const testCustomerName = 'Vamsi Krishna';
    const testCustomerNumber = '9876543210';

    final testCustomer = Customer(
      id: testCustomerId,
      userID: 1,
      name: testCustomerName,
      guardianName: 'Rama Krishna',
      address: 'Hyderabad',
      number: testCustomerNumber,
      photo: '',
      proof: '',
      createdDate: DateTime(2026),
    );

    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          appDirProvider.overrideWith((ref) => '/tmp'),
          customerProvider(testCustomerId).overrideWith(
            () => _FakeCustomerNotifier(testCustomer),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AddNewTransactionView(
            customerID: testCustomerId,
            customerName: testCustomerName,
            customerNumber: testCustomerNumber,
          ),
        ),
      );
    }

    testWidgets('renders all section headers, customer summary card and form fields cleanly', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Check section headers
      expect(find.byType(SectionHeaderWidget), findsNWidgets(4));
      expect(find.text('CUSTOMER INFORMATION'), findsOneWidget);
      expect(find.text('LOAN TERMS & INTEREST'), findsOneWidget);
      expect(find.text('COLLATERAL & DOCUMENTATION'), findsOneWidget);
      expect(find.text('BORROWER ACKNOWLEDGEMENT'), findsOneWidget);

      // Check customer identity card
      expect(find.textContaining(testCustomerName), findsNWidgets(2)); // in AppBar subtitle and customer card
      expect(find.text(testCustomerNumber), findsOneWidget);
      expect(find.text('#$testCustomerId'), findsOneWidget);

      // Check form fields
      expect(find.text('Taken amount'), findsOneWidget);
      expect(find.text('Monthly interest rate %'), findsOneWidget);
      expect(find.text('Taken date'), findsOneWidget);
      expect(find.text('Item description'), findsOneWidget);

      // Check save button
      expect(find.byType(RoundedCornerButton), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('responsive layout constrains max width to 640 on tablet/desktop viewports', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
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
  });
}
