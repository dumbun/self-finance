import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/l10n/app_localizations.dart';
import 'package:self_finance/models/dashboard_stats_model.dart';
import 'package:self_finance/providers/analytics_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/views/dashboard_view.dart';
import 'package:self_finance/widgets/app_icon_widget.dart';

class _MockTransactionsNotifier extends TransactionsNotifier {
  @override
  Future<TransactionsPaginationState> build() async =>
      const TransactionsPaginationState();
}

void main() {
  testWidgets('DashboardView renders executive AppBar and navigates tabs',
      (WidgetTester tester) async {
    const mockAnalytics = AnalyticsState(
      totalCustomers: 0,
      activeLoans: 0,
      outstandingAmount: 0.0,
      interestEarned: 0.0,
      totalDisbursed: 0.0,
      paymentsReceived: 0.0,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsProvider.overrideWith(
            (ref) => Stream.value(mockAnalytics),
          ),
          transactionsProvider.overrideWith(
            _MockTransactionsNotifier.new,
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DashboardView(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify AppBar brand and title on home tab
    expect(find.byType(AppIconWidget), findsAtLeast(1));
    expect(find.text('Self Finance'), findsAtLeast(1));
    expect(find.text('Portfolio Overview'), findsOneWidget);

    // Verify Bottom Navigation Bar exists with destinations
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byIcon(Icons.home_filled), findsOneWidget);
    expect(find.byIcon(Icons.book_outlined), findsOneWidget);
    expect(find.byIcon(Icons.calculate_outlined), findsAtLeast(1));
    expect(find.byIcon(Icons.history_toggle_off), findsOneWidget);
  });
}
