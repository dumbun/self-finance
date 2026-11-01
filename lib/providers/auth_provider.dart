import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/backend/account_database_manager.dart';
import 'package:self_finance/core/auth/firebase_auth_service.dart';

export 'package:self_finance/core/auth/firebase_auth_service.dart'
    show FirebaseUserCompat;

/// Singleton [FirebaseAuthService] wrapping the global Firebase Auth client.
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

/// Reactive stream of Firebase [User?] auth state changes.
final authStateProvider = StreamProvider<User?>((ref) {
  final service = ref.watch(firebaseAuthServiceProvider);
  return service.authStateChanges;
});

final isSignedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  final service = ref.watch(firebaseAuthServiceProvider);
  return authState.whenOrNull(data: (user) => user != null) ??
      service.isSignedIn;
});

/// The currently authenticated Firebase [User], or `null`.
final currentUserProvider = Provider<User?>((ref) {
  // Re-evaluate whenever auth state changes.
  ref.watch(authStateProvider);
  final service = ref.watch(firebaseAuthServiceProvider);
  return service.currentUser;
});

/// Opens and prepares the account database for the currently authenticated user.
final accountDatabaseProvider =
    FutureProvider.family<void, String>((ref, userId) async {
  await AccountDatabaseManager.openForAccount(userId);
});

/// State representation for the Google sign-in UI.
class GoogleSignInState {
  final bool isLoading;
  final String? errorMessage;

  const GoogleSignInState({
    this.isLoading = false,
    this.errorMessage,
  });

  GoogleSignInState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GoogleSignInState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notifier handling the business logic for Google OAuth sign-in via Firebase.
class GoogleSignInNotifier extends Notifier<GoogleSignInState> {
  @override
  GoogleSignInState build() => const GoogleSignInState();

  /// Initiates Google OAuth via [FirebaseAuthService].
  Future<void> signInWithGoogle() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final service = ref.read(firebaseAuthServiceProvider);
      await service.signInWithGoogle();
      // Success or prompt dismissed: reset loading state
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sign-in failed. Please try again.',
      );
    }
  }

  /// Handles app lifecycle resumption to unfreeze loading if the user cancelled
  /// the external Google account sheet.
  void handleAppResumed() {
    if (!state.isLoading) return;
    Future.delayed(const Duration(seconds: 1), () {
      final hasUser =
          ref.read(firebaseAuthServiceProvider).currentUser != null;
      if (!hasUser) {
        state = state.copyWith(isLoading: false);
      }
    });
  }

  /// Clears any visible error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final googleSignInProvider =
    NotifierProvider<GoogleSignInNotifier, GoogleSignInState>(
  GoogleSignInNotifier.new,
);

