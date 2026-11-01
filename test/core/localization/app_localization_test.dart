import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pinput/pinput.dart';
import 'package:self_finance/core/localization/fallback_localization_delegates.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/utility/preferences_helper.dart';
import 'package:self_finance/l10n/app_localizations.dart';
import 'package:self_finance/providers/settings_provider.dart';
import 'package:self_finance/widgets/pin_input_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLocalizations & i18n Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('supportedLocales contains en, hi, and te', () {
      final languages =
          AppLocalizations.supportedLocales.map((l) => l.languageCode).toList();
      expect(languages, containsAll(['en', 'hi', 'te']));
    });

    testWidgets('AppLocalizations loads correctly for English', (tester) async {
      late AppLocalizations localizations;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            ...AppLocalizations.localizationsDelegates,
            ...GlobalMaterialLocalizations.delegates,
            FallbackMuiMaterialLocalizationsDelegate(),
            FallbackMuiCupertinoLocalizationsDelegate(),
            FallbackMaterialLocalizationsDelegate(),
            FallbackCupertinoLocalizationsDelegate(),
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              localizations = AppLocalizations.of(context)!;
              return Text(localizations.newCustomerAndLoan);
            },
          ),
        ),
      );

      expect(localizations.appTitle, 'Self-Finance');
      expect(localizations.newCustomerAndLoan, 'New Customer & Loan');
      expect(localizations.customerInformation, 'Customer Information');
      expect(localizations.createCustomerAndLoan, 'Create Customer & Loan');
      expect(find.text('New Customer & Loan'), findsOneWidget);
    });

    testWidgets('AppLocalizations loads correctly for Hindi', (tester) async {
      late AppLocalizations localizations;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            ...AppLocalizations.localizationsDelegates,
            ...GlobalMaterialLocalizations.delegates,
            FallbackMuiMaterialLocalizationsDelegate(),
            FallbackMuiCupertinoLocalizationsDelegate(),
            FallbackMaterialLocalizationsDelegate(),
            FallbackCupertinoLocalizationsDelegate(),
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('hi'),
          home: Builder(
            builder: (context) {
              localizations = AppLocalizations.of(context)!;
              return Text(localizations.newCustomerAndLoan);
            },
          ),
        ),
      );

      expect(localizations.appTitle, 'सेल्फ-फाइनेंस');
      expect(localizations.newCustomerAndLoan, 'नया ग्राहक और ऋण');
      expect(localizations.customerInformation, 'ग्राहक जानकारी');
      expect(localizations.createCustomerAndLoan, 'ग्राहक और ऋण बनाएं');
      expect(find.text('नया ग्राहक और ऋण'), findsOneWidget);
    });

    testWidgets('AppLocalizations loads correctly for Telugu', (tester) async {
      late AppLocalizations localizations;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            ...AppLocalizations.localizationsDelegates,
            ...GlobalMaterialLocalizations.delegates,
            FallbackMuiMaterialLocalizationsDelegate(),
            FallbackMuiCupertinoLocalizationsDelegate(),
            FallbackMaterialLocalizationsDelegate(),
            FallbackCupertinoLocalizationsDelegate(),
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('te'),
          home: Builder(
            builder: (context) {
              localizations = AppLocalizations.of(context)!;
              return Text(localizations.newCustomerAndLoan);
            },
          ),
        ),
      );

      expect(localizations.appTitle, 'సెల్ఫ్-ఫైనాన్స్');
      expect(localizations.newCustomerAndLoan, 'కొత్త కస్టమర్ & రుణం');
      expect(localizations.customerInformation, 'కస్టమర్ సమాచారం');
      expect(localizations.createCustomerAndLoan, 'కస్టమర్ & రుణం సృష్టించండి');
      expect(find.text('కొత్త కస్టమర్ & రుణం'), findsOneWidget);
    });

    testWidgets(
        'PinInputWidget (Pinput) and material_ui widgets find MaterialLocalizations without throwing',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            ...AppLocalizations.localizationsDelegates,
            ...GlobalMaterialLocalizations.delegates,
            FallbackMuiMaterialLocalizationsDelegate(),
            FallbackMuiCupertinoLocalizationsDelegate(),
            FallbackMaterialLocalizationsDelegate(),
            FallbackCupertinoLocalizationsDelegate(),
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            appBar: AppBar(title: const Text('Title')),
            body: PinInputWidget(
              pinController: controller,
              obscureText: true,
            ),
          ),
        ),
      );

      expect(find.byType(PinInputWidget), findsOneWidget);
      expect(find.byType(Pinput), findsOneWidget);
    });

    test('PreferencesHelper getLocaleCode and setLocaleCode work properly',
        () async {
      expect(await PreferencesHelper.getLocaleCode(), isNull);

      await PreferencesHelper.setLocaleCode('hi');
      expect(await PreferencesHelper.getLocaleCode(), 'hi');

      await PreferencesHelper.setLocaleCode('te');
      expect(await PreferencesHelper.getLocaleCode(), 'te');

      await PreferencesHelper.setLocaleCode(null);
      expect(await PreferencesHelper.getLocaleCode(), isNull);
    });

    testWidgets('LocaleNotifier updates locale and persists preference',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialLocale = await container.read(localeProvider.future);
      expect(initialLocale, isNull);

      await container
          .read(localeProvider.notifier)
          .setLocale(const Locale('hi'));
      expect(container.read(localeProvider).value?.languageCode, 'hi');
      expect(await PreferencesHelper.getLocaleCode(), 'hi');

      await container.read(localeProvider.notifier).setLocale(null);
      expect(container.read(localeProvider).value, isNull);
      expect(await PreferencesHelper.getLocaleCode(), isNull);
    });

    testWidgets(
        'Dynamic locale switching updates UI across the application immediately',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              final localeAsync = ref.watch(localeProvider);
              return MaterialApp(
                locale: localeAsync.value,
                localizationsDelegates: const [
                  ...AppLocalizations.localizationsDelegates,
                  ...GlobalMaterialLocalizations.delegates,
                  FallbackMuiMaterialLocalizationsDelegate(),
                  FallbackMuiCupertinoLocalizationsDelegate(),
                  FallbackMaterialLocalizationsDelegate(),
                  FallbackCupertinoLocalizationsDelegate(),
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: Builder(
                    builder: (innerContext) {
                      final l10n = innerContext.l10n;
                      return Column(
                        children: [
                          Text(l10n.home),
                          Text(l10n.transactions),
                          Text(l10n.accountSettings),
                          Text(l10n.profile),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially English
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('Account settings'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Change locale to Hindi
      final element = tester.element(find.byType(Scaffold));
      final container = ProviderScope.containerOf(element);
      await container
          .read(localeProvider.notifier)
          .setLocale(const Locale('hi'));
      await tester.pumpAndSettle();

      // Verified updated to Hindi across all widgets
      expect(find.text('होम'), findsOneWidget);
      expect(find.text('लेन-देन'), findsOneWidget);
      expect(find.text('खाता सेटिंग्स'), findsOneWidget);
      expect(find.text('प्रोफ़ाइल'), findsOneWidget);

      // Change locale to Telugu
      await container
          .read(localeProvider.notifier)
          .setLocale(const Locale('te'));
      await tester.pumpAndSettle();

      // Verified updated to Telugu across all widgets
      expect(find.text('హోమ్'), findsOneWidget);
      expect(find.text('లావాదేవీలు'), findsOneWidget);
      expect(find.text('ఖాతా సెట్టింగ్‌లు'), findsOneWidget);
      expect(find.text('ప్రొఫైల్'), findsOneWidget);
    });
  });
}
