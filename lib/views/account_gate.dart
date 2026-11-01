import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    if (!Utility.isFirebaseInitialized) {
      return const AuthView();
    }

    final authState = ref.watch(authStateProvider);
    final authService = ref.watch(firebaseAuthServiceProvider);
    final currentUser = authState.asData?.value ?? authService.currentUser;

    if (currentUser != null) {
      final dbInit = ref.watch(accountDatabaseProvider(currentUser.uid));
      return dbInit.when(
        data: (_) => const AuthView(),
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
        error: (error, _) {
          debugPrint('Account database init error: $error');
          return const AuthView();
        },
      );
    }

    if (authState.isLoading && authService.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }

    return const GoogleSignInView();
  }
}
