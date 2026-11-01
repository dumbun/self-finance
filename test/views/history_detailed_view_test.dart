import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/l10n/app_localizations.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history_model.dart';
import 'package:self_finance/providers/app_dir_provider.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/views/history/history_detailed_view.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/status_chip_widget.dart';

class _FakeCustomerNotifier extends CustomerNotifier {
  _FakeCustomerNotifier(this.customer);
  final Customer? customer;

  @override
  Stream<Customer?> build(String id) => Stream.value(customer);
}

class _FakeTransactionByIDNotifier extends TransactionByID {
  _FakeTransactionByIDNotifier(this.trx);
  final Trx? trx;

  @override
  Stream<Trx?> build(String transactionId) => Stream.value(trx);
}

void main() {
  group('HistoryDetailedView tests', () {
    final testHistory = UserHistory(
      id: '42',
      userID: 1,
      customerID: '10',
      itemID: '5',
      customerNumber: '9876543210',
      customerName: 'John Doe',
      transactionID: '99',
      eventDate: DateTime(2026, 10, 20, 14, 30),
      eventType: Constant.debited,
      amount: 15000.0,
    );

    testWidgets('renders hero amount card, customer details and linked loan correctly', (tester) async {
      final testCustomer = Customer(
        id: '10',
        userID: 1,
        name: 'John Doe',
        guardianName: 'Guardian Doe',
        address: 'Main Street 123',
        number: '9876543210',
        photo: '',
        proof: '',
        createdDate: DateTime(2026),
      );

      final testTrx = Trx(
        id: '99',
        customerId: '10',
        itemId: '5',
        transacrtionDate: DateTime(2026, 10, 15),
        transacrtionType: Constant.active,
        amount: 15000.0,
        intrestRate: 2.0,
        intrestAmount: 300.0,
        remainingAmount: 15000.0,
        signature: '',
        createdDate: DateTime(2026, 10, 15),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDirProvider.overrideWithValue('/test/dir'),
            customerProvider('10').overrideWith(() => _FakeCustomerNotifier(testCustomer)),
            transactionByIDProvider('99').overrideWith(() => _FakeTransactionByIDNotifier(testTrx)),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HistoryDetailedView(history: testHistory),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and Reference ID
      expect(find.text('History Details'), findsOneWidget);
      expect(find.text('Reference #42'), findsOneWidget);
      expect(find.text('PAID OUT (DEBIT)'), findsOneWidget);

      // Check CurrencyWidget renders amount
      expect(find.byType(CurrencyWidget), findsWidgets);

      // Check Customer Details
      expect(find.text('Customer Details'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('9876543210'), findsOneWidget);

      // Check Transaction Details Card
      expect(find.text('Transaction Details'), findsOneWidget);
      expect(find.byType(StatusChipWidget), findsOneWidget);
      expect(find.text('Show Transaction Details'), findsOneWidget);

      // Check Share button exists
      expect(find.text('Share Receipt'), findsOneWidget);
    });

    testWidgets('gracefully handles missing linked transaction without crashing', (tester) async {
      final historyWithoutLoan = testHistory.copyWith(transactionID: '');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDirProvider.overrideWithValue('/test/dir'),
            customerProvider('10').overrideWith(() => _FakeCustomerNotifier(null)),
            requriedCustomerTransactionsProvider('10').overrideWith((ref) => Stream.value(<Trx>[])),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HistoryDetailedView(history: historyWithoutLoan),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Fallback name is rendered from history model
      expect(find.text('John Doe'), findsOneWidget);
      // Fallback message & Show Transaction Details button are rendered
      expect(find.text('Show Transaction Details'), findsOneWidget);
      expect(find.text('Share Receipt'), findsOneWidget);
    });
  });
}
