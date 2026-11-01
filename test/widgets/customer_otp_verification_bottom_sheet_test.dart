import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:self_finance/l10n/app_localizations.dart';
import 'package:self_finance/widgets/customer_otp_verification_bottom_sheet.dart';

Widget createTestApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('renders OTP verification bottom sheet correctly', (tester) async {
    await tester.pumpWidget(
      createTestApp(
        const CustomerOtpVerificationBottomSheet(
          customerName: 'Kiran Patel',
          phoneNumber: '+91 9988776655',
          loanAmount: 15000,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Customer OTP Verification'), findsOneWidget);
    expect(
      find.textContaining('Kiran Patel (+91 9988776655)'),
      findsOneWidget,
    );
    expect(find.text('Enter 4-Digit Verification Code'), findsOneWidget);
    expect(find.text('Verify & Confirm'), findsOneWidget);
    expect(find.text('Open SMS App'), findsOneWidget);
  });

  testWidgets('cancels bottom sheet when close button is pressed', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    String? dialogResult;

    await tester.pumpWidget(
      createTestApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              dialogResult = await CustomerOtpVerificationBottomSheet.show(
                context: context,
                customerName: 'Kiran Patel',
                phoneNumber: '+91 9988776655',
                loanAmount: 15000,
              );
            },
            child: const Text('Open Sheet'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Sheet'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Customer OTP Verification'), findsOneWidget);

    // Tap the close button
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(dialogResult, isNull);
  });
}
