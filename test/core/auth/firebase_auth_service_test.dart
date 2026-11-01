import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/core/auth/firebase_auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebaseAuthService offline/uninitialized tests', () {
    test('handles null/uninitialized auth gracefully', () {
      final service = FirebaseAuthService();

      expect(service.isAvailable, isFalse);
      expect(service.currentUser, isNull);
      expect(service.isSignedIn, isFalse);
    });

    test('authStateChanges returns empty stream when auth is null', () async {
      final service = FirebaseAuthService();
      final events = await service.authStateChanges.toList();
      expect(events, isEmpty);
    });

    test('signInWithGoogle throws StateError when auth is null', () async {
      final service = FirebaseAuthService();
      expect(
        service.signInWithGoogle,
        throwsA(isA<StateError>()),
      );
    });

    test('signOut completes without error when auth is null', () async {
      final service = FirebaseAuthService();
      await expectLater(service.signOut(), completes);
    });
  });
}
