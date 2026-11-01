import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Extension providing backwards-compatible properties on [User]
/// for downstream consumers migrating from Supabase to Firebase.
extension FirebaseUserCompat on User {
  /// Aliases [uid] as [id] for compatibility with existing database managers and sync services.
  String get id => uid;

  /// Provides mock userMetadata matching the Supabase format.
  Map<String, dynamic> get userMetadata => {
        'full_name': displayName,
        'name': displayName,
        'email': email,
      };
}

/// Wraps [FirebaseAuth] and [GoogleSignIn] to provide native Google Sign-In and sign-out.
///
/// This service is the single source of truth for cloud authentication state.
/// It does **not** manage local PIN or biometric access — those remain in [AuthView] and [PinAuthView].
class FirebaseAuthService {
  /// OAuth 2.0 Web Client ID from Firebase Console / Google Cloud Console.
  /// Used by Android to request an ID token with the matching Firebase audience.
  static const String serverClientId =
      '283235566512-9ggdpqad7lbs7j5t4ktq213lnc0ico4c.apps.googleusercontent.com';

  FirebaseAuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ??
            (Firebase.apps.isNotEmpty ? FirebaseAuth.instance : null),
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              serverClientId: serverClientId,
            );

  final FirebaseAuth? _auth;
  final GoogleSignIn _googleSignIn;

  /// Whether the Firebase Auth client is available and initialized.
  bool get isAvailable => _auth != null;

  /// The currently authenticated Firebase user, or `null` if signed out or uninitialized.
  User? get currentUser => _auth?.currentUser;

  /// Whether a Firebase session is active.
  bool get isSignedIn => currentUser != null;

  /// Reactive stream of auth state changes (sign-in, sign-out, token refresh).
  Stream<User?> get authStateChanges =>
      _auth?.authStateChanges() ?? const Stream<User?>.empty();

  /// Starts the native Google Sign-In flow (bottom sheet account picker).
  Future<UserCredential?> signInWithGoogle() async {
    final auth = _auth;
    if (auth == null) {
      throw StateError('Firebase is not initialized.');
    }

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the prompt
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Firebase Google sign-in error: $e');
      rethrow;
    }
  }

  /// Signs out of both Firebase Auth and GoogleSignIn.
  Future<void> signOut() async {
    try {
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        debugPrint('GoogleSignIn signOut ignored error: $e');
      }
      if (_auth != null) {
        await _auth.signOut();
      }
    } catch (e) {
      debugPrint('Firebase sign-out error: $e');
      rethrow;
    }
  }
}
