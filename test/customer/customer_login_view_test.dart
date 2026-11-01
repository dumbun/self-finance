import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/customer/providers/customer_portal_provider.dart';
import 'package:self_finance/customer/views/customer_login_view.dart';
import 'package:self_finance/l10n/app_localizations.dart';
import 'package:self_finance/widgets/country_code_picker_widget.dart';
import 'package:self_finance/widgets/pin_input_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthNotifier extends CustomerPortalAuthNotifier {
  final CustomerPortalAuthState initialState;
  _FakeAuthNotifier(this.initialState);

  @override
  CustomerPortalAuthState build() => initialState;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CustomerLoginView renders initial login form with phone input',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerPortalAuthProvider.overrideWith(
            () => _FakeAuthNotifier(const CustomerPortalAuthState()),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CustomerLoginView(),
        ),
      ),
    );
    await tester.pump();

    // Verify title and subtitle
    expect(find.text('Customer / Borrower Login'), findsOneWidget);
    expect(
      find.text(
          'Enter your registered mobile number to view your loans & transactions'),
      findsOneWidget,
    );

    // Verify country picker and input field
    expect(find.byType(CountryCodePickerWidget), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Verify Send Verification Code button
    expect(find.byType(RoundedCornerButton), findsOneWidget);
    expect(find.text('Send Verification Code'), findsOneWidget);

    // Verify Back to Lender Login button exists
    expect(find.text('Back to Lender Login'), findsOneWidget);
  });

  testWidgets('CustomerLoginView renders OTP verification form when isOtpSent is true',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerPortalAuthProvider.overrideWith(
            () => _FakeAuthNotifier(
              const CustomerPortalAuthState(
                isOtpSent: true,
                customerName: 'Anil Kumar',
                sessionId: 'mock-session-123',
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CustomerLoginView(),
        ),
      ),
    );
    await tester.pump();

    // Verify greeting and PIN input
    expect(find.text('Hello, Anil Kumar!'), findsOneWidget);
    expect(find.byType(PinInputWidget), findsOneWidget);
    expect(find.text('Verify & View Loans'), findsOneWidget);
    expect(find.text('Change Number'), findsOneWidget);
  });

  testWidgets(
      'CustomerLoginView renders automated 6-digit SMS verification form when isAutomated is true',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerPortalAuthProvider.overrideWith(
            () => _FakeAuthNotifier(
              const CustomerPortalAuthState(
                isOtpSent: true,
                isAutomated: true,
                codeLength: 6,
                customerName: 'Priya Sharma',
                phoneNumber: '+91 9876543210',
                verificationId: 'mock-verification-id-456',
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CustomerLoginView(),
        ),
      ),
    );
    await tester.pump();

    // Verify greeting, automated instructions, and dynamic PIN widget
    expect(find.text('Hello, Priya Sharma!'), findsOneWidget);
    expect(find.text('Enter 6-digit verification code'), findsOneWidget);
    expect(
      find.text('SMS verification code sent to +91 9876543210'),
      findsOneWidget,
    );
    final pinWidgetFinder = find.byType(PinInputWidget);
    expect(pinWidgetFinder, findsOneWidget);
    final pinWidget = tester.widget<PinInputWidget>(pinWidgetFinder);
    expect(pinWidget.length, 6);

    expect(find.text('Verify & View Loans'), findsOneWidget);
  });
}
