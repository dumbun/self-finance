import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/l10n/app_localizations.dart';
import 'package:self_finance/models/dashboard_stats_model.dart';
import 'package:self_finance/models/trx_with_customer_model.dart';
import 'package:self_finance/providers/analytics_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/views/home_screen.dart';

class _MockTransactionsNotifier extends TransactionsNotifier {
  final TransactionsPaginationState paginationState;
  _MockTransactionsNotifier(this.paginationState);

  @override
  Future<TransactionsPaginationState> build() async => paginationState;
}

void main() {
  testWidgets('HomeScreen renders executive hero card, quick actions, and analytics',
      (WidgetTester tester) async {
    const mockAnalytics = AnalyticsState(
      totalCustomers: 5,
      activeLoans: 3,
      outstandingAmount: 75000.0,
      interestEarned: 8500.0,
      totalDisbursed: 150000.0,
      paymentsReceived: 75000.0,
    );

    final mockPagination = TransactionsPaginationState(
      transactions: [
        TrxWithCustomer(
          id: 'trx-101',
          customerId: 'cust-1',
          itemId: 'item-1',
          transactionDate: DateTime(2026, 1, 15),
          transactionType: 'Active',
          amount: 50000.0,
          interestRate: 2.0,
          interestAmount: 1000.0,
          remainingAmount: 25000.0,
          signature: '',
          createdDate: DateTime(2026, 1, 15),
          customerName: 'Anil Kumar',
          customerPhoto: '',
        ),
      ],
      hasMore: false,
    );

    int? navigatedTab;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsProvider.overrideWith(
            (ref) => Stream.value(mockAnalytics),
          ),
          transactionsProvider.overrideWith(
            () => _MockTransactionsNotifier(mockPagination),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: HomeScreen(
              onNavigateToTab: (tabIndex) {
                navigatedTab = tabIndex;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Executive Greeting & Date Pill
    expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);

    // Verify Hero Portfolio Balance Card elements
    expect(find.text('Active Portfolio Balance'), findsOneWidget);
    expect(find.text('Total Disbursed'), findsAtLeast(1));
    expect(find.text('Payments Received'), findsAtLeast(1));
    expect(find.textContaining('3 Active'), findsOneWidget);
    expect(find.textContaining('5 Total Customers'), findsOneWidget);

    // Verify Quick Action Buttons
    expect(find.text('New Loan'), findsAtLeast(1));
    expect(find.text('Borrowers'), findsOneWidget);
    expect(find.text('Ledger'), findsOneWidget);
    expect(find.text('EMI Calculator'), findsOneWidget);

    // Verify clicking "Ledger" calls onNavigateToTab with 1
    await tester.tap(find.text('Ledger'));
    expect(navigatedTab, 1);

    // Verify clicking "EMI Calculator" calls onNavigateToTab with 2
    await tester.tap(find.text('EMI Calculator'));
    expect(navigatedTab, 2);

    // Verify Section Headers
    expect(find.text('Cashflow Analytics'), findsOneWidget);

    // Scroll to reveal Business Breakdown
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pump();
    expect(find.text('Business Breakdown'), findsOneWidget);

    // Scroll to reveal Recent Activity
    await tester.scrollUntilVisible(
      find.text('Recent Activity'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(find.text('Recent Activity'), findsOneWidget);

    // Verify Recent transaction card rendered
    expect(find.text('Anil Kumar'), findsOneWidget);
  });
}
