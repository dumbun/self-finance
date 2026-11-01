import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/customer/models/customer_portal_models.dart';
import 'package:self_finance/customer/providers/customer_portal_provider.dart';
import 'package:self_finance/customer/views/customer_dashboard_view.dart';
import 'package:self_finance/customer/views/customer_loan_detail_view.dart';
import 'package:self_finance/l10n/app_localizations.dart';
import 'package:self_finance/widgets/status_chip_widget.dart';

CustomerPortalData _createMockPortalData() {
  return CustomerPortalData(
    customer: CustomerPortalProfile(
      name: 'Ramesh Kumar',
      guardianName: 'Suresh Kumar',
      contactNumber: '+91 9876543210',
      address: 'Plot 42, Hyderabad',
      photoPath: '',
      proofPath: '',
    ),
    summary: CustomerPortalSummary(
      totalLoans: 1,
      totalBorrowed: 50000.0,
      totalRemaining: 25000.0,
      totalPaid: 25000.0,
    ),
    loans: [
      CustomerPortalLoan(
        transactionId: 'txn-101',
        amount: 50000.0,
        interestRate: 2.0,
        interestAmount: 1000.0,
        remainingAmount: 25000.0,
        transactionDate: DateTime(2026, 1, 15),
        transactionType: 'Active',
        signaturePath: '',
        itemName: 'Gold Chain 22K',
        itemDescription: 'Hallmarked 16g',
        pawnAmount: 50000.0,
        itemStatus: 'Active',
        pawnedDate: DateTime(2026, 1, 15),
        expiryDate: DateTime(2026, 7, 15),
        itemPhotoPath: '',
      ),
    ],
    payments: [
      CustomerPortalPayment(
        paymentId: 'pay-201',
        transactionId: 'txn-101',
        amountPaid: 25000.0,
        paymentType: 'Principal',
        paymentDate: DateTime(2026, 2, 20),
      ),
    ],
  );
}

void main() {
  testWidgets('CustomerDashboardView displays customer profile and loans',
      (WidgetTester tester) async {
    final mockData = _createMockPortalData();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerPortalDataProvider
              .overrideWith((ref) => Future.value(mockData)),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CustomerDashboardView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify customer header info
    expect(find.text('Ramesh Kumar'), findsOneWidget);
    expect(find.text('+91 9876543210'), findsOneWidget);
    expect(find.text('c/o Suresh Kumar'), findsOneWidget);

    // Verify financial summary cards
    expect(find.text('Remaining Balance'), findsOneWidget);
    expect(find.text('Total Borrowed'), findsOneWidget);
    expect(find.text('Total Paid'), findsOneWidget);

    // Verify tabs
    expect(find.text('Active (1)'), findsOneWidget);
    expect(find.text('My Loans (1)'), findsOneWidget);
    expect(find.text('Payment History (1)'), findsOneWidget);

    // Verify loan card content and status chip
    expect(find.text('Gold Chain 22K'), findsOneWidget);
    expect(find.byType(StatusChipWidget), findsAtLeast(1));
  });

  testWidgets('CustomerLoanDetailView displays collateral and loan terms',
      (WidgetTester tester) async {
    final mockData = _createMockPortalData();
    final loan = mockData.loans.first;
    final payments = mockData.payments;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CustomerLoanDetailView(
            loan: loan,
            payments: payments,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify loan title and collateral
    expect(find.text('Loan Details'), findsOneWidget);
    expect(find.text('Collateral Item'), findsOneWidget);
    expect(find.text('Gold Chain 22K'), findsOneWidget);
    expect(find.text('Hallmarked 16g'), findsOneWidget);

    // Verify payment record
    expect(find.text('Payment History'), findsOneWidget);
    expect(find.text('Principal'), findsOneWidget);
  });
}
