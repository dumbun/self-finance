import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:self_finance/backend/account_database_manager.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/providers/auth_provider.dart';
import 'package:self_finance/views/auth_view.dart';
import 'package:self_finance/views/google_sign_in_view.dart';

/// Reactive gate that sits between the splash screen and the existing
/// PIN/biometric authentication flow.
///
/// All expensive database preparation is completed in [SplashScreen] before
/// this gate is shown, so the user never sees an intermediate loading view.
class AccountGate extends ConsumerWidget {
  const AccountGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!Utility.isSupabaseInitialized) {
      return const AuthView();
    }

    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (AuthState state) {
        if (state.session != null) {
          return const AuthView();
        }

        AccountDatabaseManager.closeCurrentAccount();
        return const GoogleSignInView();
      },
      loading: () => const AuthView(),
      error: (error, _) {
        debugPrint('Auth state error: $error');
        return const GoogleSignInView();
      },
    );
  }
}
