import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:self_finance/models/country_model.dart';
import 'package:self_finance/widgets/country_code_picker_widget.dart';

void main() {
  group('Country Model Tests', () {
    test('defaultCountry is India (+91)', () {
      expect(Country.defaultCountry.name, 'India');
      expect(Country.defaultCountry.dialCode, '+91');
      expect(Country.defaultCountry.code, 'IN');
      expect(Country.defaultCountry.flag, '🇮🇳');
    });

    test('fromDialCode returns matching country or fallback default', () {
      final us = Country.fromDialCode('+1');
      expect(us.name, 'United States');
      expect(us.code, 'US');

      final uae = Country.fromDialCode('+971');
      expect(uae.name, 'United Arab Emirates');

      final unknown = Country.fromDialCode('+99999');
      expect(unknown, Country.defaultCountry);
    });

    test('equality and hashcode are consistent', () {
      const c1 = Country(name: 'India', code: 'IN', dialCode: '+91', flag: '🇮🇳');
      const c2 = Country(name: 'India', code: 'IN', dialCode: '+91', flag: '🇮🇳');
      expect(c1, equals(c2));
      expect(c1.hashCode, equals(c2.hashCode));
    });
  });

  group('CountryCodePickerWidget Widget Tests', () {
    testWidgets('renders selected country flag and dial code', (tester) async {
      Country selected = Country.defaultCountry;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryCodePickerWidget(
              selectedCountry: selected,
              onChanged: (c) => selected = c,
            ),
          ),
        ),
      );

      expect(find.text('🇮🇳'), findsOneWidget);
      expect(find.text('+91'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });

    testWidgets('tapping opens country selection sheet and filters countries by search', (tester) async {
      Country selected = Country.defaultCountry;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryCodePickerWidget(
              selectedCountry: selected,
              onChanged: (c) => selected = c,
            ),
          ),
        ),
      );

      // Tap picker
      await tester.tap(find.byType(CountryCodePickerWidget));
      await tester.pumpAndSettle();

      // Verify sheet is open
      expect(find.text('Select Country'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Search for United Kingdom
      await tester.enterText(find.byType(TextField), 'Kingdom');
      await tester.pumpAndSettle();

      expect(find.text('United Kingdom'), findsOneWidget);
      expect(find.text('+44'), findsOneWidget);

      // Select United Kingdom
      await tester.tap(find.text('United Kingdom'));
      await tester.pumpAndSettle();

      // Verify sheet closed and country selected
      expect(find.text('Select Country'), findsNothing);
      expect(selected.dialCode, '+44');
      expect(selected.code, 'GB');
    });

    testWidgets('disabled picker does not open bottom sheet on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryCodePickerWidget(
              selectedCountry: Country.defaultCountry,
              enabled: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CountryCodePickerWidget));
      await tester.pumpAndSettle();

      expect(find.text('Select Country'), findsNothing);
    });
  });
}
