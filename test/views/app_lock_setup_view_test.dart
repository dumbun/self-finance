import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart' as native_loc;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/views/app_lock_setup_view.dart';
import 'package:self_finance/widgets/currency_type_input_widget.dart';
import 'package:self_finance/widgets/pin_input_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';

void main() {
  testWidgets('AppLockSetupView renders all setup inputs and validates', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            native_loc.GlobalMaterialLocalizations.delegate,
            native_loc.GlobalWidgetsLocalizations.delegate,
            native_loc.GlobalCupertinoLocalizations.delegate,
          ],
          home: AppLockSetupView(),
        ),
      ),
    );

    // Verify header and title
    expect(find.text('Set App Lock & Currency'), findsOneWidget);
    expect(find.text('Primary Currency'), findsOneWidget);
    expect(find.text('Create 4-Digit App Lock PIN'), findsOneWidget);
    expect(find.text('Confirm 4-Digit PIN'), findsOneWidget);

    // Verify widgets exist
    expect(find.byType(CurrencyTypeInputWidget), findsOneWidget);
    expect(find.byType(PinInputWidget), findsNWidgets(2));
    expect(find.byType(RoundedCornerButton), findsOneWidget);
    expect(find.text('Finish Setup & Go to Dashboard'), findsOneWidget);
  });
}
