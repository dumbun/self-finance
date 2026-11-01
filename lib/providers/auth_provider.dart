import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:self_finance/backend/account_database_manager.dart';
import 'package:self_finance/core/auth/supabase_auth_service.dart';
import 'package:self_finance/core/utility/user_utility.dart';

/// Singleton [SupabaseAuthService] wrapping the global Supabase client.
final supabaseAuthServiceProvider = Provider<SupabaseAuthService>((ref) {
  if (!Utility.isSupabaseInitialized) {
    return SupabaseAuthService(null);
  }
  return SupabaseAuthService(Supabase.instance.client);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final service = ref.watch(supabaseAuthServiceProvider);
  return service.authChanges;
});

final isSignedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  final service = ref.watch(supabaseAuthServiceProvider);
  return authState.whenOrNull(data: (state) => state.session != null) ??
      service.isSignedIn;
});

/// The currently authenticated [User], or `null`.
final currentUserProvider = Provider<User?>((ref) {
  // Re-evaluate whenever auth state changes.
  ref.watch(authStateProvider);
  final service = ref.watch(supabaseAuthServiceProvider);
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

/// Notifier handling the business logic for Google OAuth sign-in.
class GoogleSignInNotifier extends Notifier<GoogleSignInState> {
  @override
  GoogleSignInState build() => const GoogleSignInState();

  /// Initiates Google OAuth via [SupabaseAuthService].
  Future<void> signInWithGoogle() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final service = ref.read(supabaseAuthServiceProvider);
      await service.signInWithGoogle();
      // Success: auth stream will trigger navigation; reset loading state
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sign-in failed. Please try again.',
      );
    }
  }

  /// Handles app lifecycle resumption to unfreeze loading if the user cancelled
  /// the external browser OAuth prompt.
  void handleAppResumed() {
    if (!state.isLoading) return;
    Future.delayed(const Duration(seconds: 2), () {
      final hasSession =
          ref.read(supabaseAuthServiceProvider).currentSession != null;
      if (!hasSession) {
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

