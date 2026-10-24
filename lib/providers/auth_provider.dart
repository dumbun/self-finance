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
  return authState.whenOrNull(data: (state) => state.session != null) ??
      (Utility.isSupabaseInitialized &&
          Supabase.instance.client.auth.currentSession != null);
});

/// The currently authenticated [User], or `null`.
final currentUserProvider = Provider<User?>((ref) {
  // Re-evaluate whenever auth state changes.
  ref.watch(authStateProvider);
  if (!Utility.isSupabaseInitialized) return null;
  return Supabase.instance.client.auth.currentUser;
});

/// Opens and prepares the account database for the currently authenticated user.
final accountDatabaseProvider =
    FutureProvider.family<void, String>((ref, userId) async {
  await AccountDatabaseManager.openForAccount(userId);
});

