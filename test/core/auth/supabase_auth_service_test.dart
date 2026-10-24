import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/core/auth/supabase_auth_service.dart';

void main() {
  group('SupabaseAuthService offline/uninitialized tests', () {
    test('handles null client gracefully', () {
      final service = SupabaseAuthService(null);

      expect(service.isAvailable, isFalse);
      expect(service.currentUser, isNull);
      expect(service.isSignedIn, isFalse);
      expect(service.currentSession, isNull);
    });

    test('authChanges returns empty stream when client is null', () async {
      final service = SupabaseAuthService(null);
      final events = await service.authChanges.toList();
      expect(events, isEmpty);
    });

    test('signInWithGoogle throws StateError when client is null', () async {
      final service = SupabaseAuthService(null);
      expect(
        service.signInWithGoogle,
        throwsA(isA<StateError>()),
      );
    });

    test('signOut completes without error when client is null', () async {
      final service = SupabaseAuthService(null);
      await expectLater(service.signOut(), completes);
    });
  });
}
