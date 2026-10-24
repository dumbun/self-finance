import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Wraps [SupabaseClient.auth] to provide Google OAuth sign-in and sign-out.
///
/// This service is the single source of truth for authentication state.
/// It does **not** manage local PIN or biometric access — those remain
/// in [AuthView] and [PinAuthView].
class SupabaseAuthService {
  SupabaseAuthService(this._client);

  final SupabaseClient? _client;

  /// Whether the Supabase client is available.
  bool get isAvailable => _client != null;

  /// The currently authenticated Supabase user, or `null` if signed out or uninitialized.
  User? get currentUser => _client?.auth.currentUser;

  /// Whether a Supabase session is active.
  bool get isSignedIn => currentUser != null;

  /// Reactive stream of auth state changes (sign-in, sign-out, token refresh).
  Stream<AuthState> get authChanges =>
      _client?.auth.onAuthStateChange ?? const Stream<AuthState>.empty();

  /// The current session, if any.
  Session? get currentSession => _client?.auth.currentSession;

  /// Starts the Google OAuth flow in an external browser.
  ///
  /// The redirect URI must match:
  /// - Android: `intent-filter` in `AndroidManifest.xml`
  /// - iOS: `CFBundleURLSchemes` in `Info.plist`
  /// - Supabase dashboard: allowed redirect URLs
  Future<bool> signInWithGoogle() async {
    final client = _client;
    if (client == null) {
      throw StateError(
        'Supabase is not configured. Please supply SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY in .env.',
      );
    }

    try {
      final success = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'selffinance://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      return success;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      rethrow;
    }
  }

  /// Signs out the current Supabase session.
  ///
  /// After calling this, [currentUser] returns `null` and [authChanges]
  /// emits a sign-out event, which causes the account gate to show the
  /// sign-in screen.
  Future<void> signOut() async {
    final client = _client;
    if (client == null) return;

    try {
      await client.auth.signOut();
    } catch (e) {
      debugPrint('Sign-out error: $e');
      rethrow;
    }
  }
}

