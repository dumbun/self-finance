import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/providers/app_lock_setup_provider.dart';

void main() {
  group('AppLockSetupNotifier tests', () {
    test('initial state has default values and empty suggested name when unauthenticated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(appLockSetupProvider);
      expect(state.isLoading, isFalse);
      expect(state.isSuccess, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.defaultCurrency, equals('₹'));
      expect(state.initialName, isEmpty);
    });

    test('completeSetup rejects PIN with length != 4', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appLockSetupProvider.notifier);
      final result = await notifier.completeSetup(
        name: 'Test User',
        currency: '₹',
        pin: '12',
        confirmPin: '12',
      );

      expect(result, isFalse);
      final state = container.read(appLockSetupProvider);
      expect(state.errorMessage, equals('Please enter a 4-digit PIN'));
      expect(state.isLoading, isFalse);
      expect(state.isSuccess, isFalse);
    });

    test('completeSetup rejects mismatched PINs', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appLockSetupProvider.notifier);
      final result = await notifier.completeSetup(
        name: 'Test User',
        currency: '₹',
        pin: '1234',
        confirmPin: '1235',
      );

      expect(result, isFalse);
      final state = container.read(appLockSetupProvider);
      expect(state.errorMessage, equals('PINs do not match. Please verify.'));
      expect(state.isLoading, isFalse);
      expect(state.isSuccess, isFalse);
    });

    test('clearError resets errorMessage', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appLockSetupProvider.notifier);
      await notifier.completeSetup(
        name: 'Test User',
        currency: '₹',
        pin: '12',
        confirmPin: '12',
      );
      expect(container.read(appLockSetupProvider).errorMessage, isNotNull);

      notifier.clearError();
      expect(container.read(appLockSetupProvider).errorMessage, isNull);
    });

    test('copyWith updates state correctly and clearError flag works', () {
      const state = AppLockSetupState();
      final updated = state.copyWith(
        isLoading: true,
        errorMessage: 'Some error',
        initialName: 'John',
      );

      expect(updated.isLoading, isTrue);
      expect(updated.errorMessage, equals('Some error'));
      expect(updated.initialName, equals('John'));

      final cleared = updated.copyWith(clearError: true);
      expect(cleared.errorMessage, isNull);
      expect(cleared.initialName, equals('John'));
    });
  });
}
