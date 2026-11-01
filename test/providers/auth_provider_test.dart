import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/providers/auth_provider.dart';

void main() {
  group('GoogleSignInNotifier tests', () {
    test('initial state has isLoading false and errorMessage null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(googleSignInProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('signInWithGoogle handles failure gracefully and sets errorMessage', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(googleSignInProvider.notifier);
      await notifier.signInWithGoogle();

      final state = container.read(googleSignInProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, equals('Sign-in failed. Please try again.'));
    });

    test('clearError resets errorMessage to null', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(googleSignInProvider.notifier);
      await notifier.signInWithGoogle();
      expect(container.read(googleSignInProvider).errorMessage, isNotNull);

      notifier.clearError();
      expect(container.read(googleSignInProvider).errorMessage, isNull);
    });

    test('handleAppResumed does nothing if not currently loading', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(googleSignInProvider.notifier);
      notifier.handleAppResumed();

      final state = container.read(googleSignInProvider);
      expect(state.isLoading, isFalse);
    });
  });

  group('Auth provider state tests', () {
    test('isSignedInProvider returns false when uninitialized or offline', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final isSignedIn = container.read(isSignedInProvider);
      expect(isSignedIn, isFalse);
    });

    test('currentUserProvider returns null when uninitialized or offline', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final currentUser = container.read(currentUserProvider);
      expect(currentUser, isNull);
    });

    test('firebaseAuthServiceProvider returns service with null user when offline', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final authService = container.read(firebaseAuthServiceProvider);
      expect(authService.currentUser, isNull);
      expect(authService.isSignedIn, isFalse);
    });
  });
}

