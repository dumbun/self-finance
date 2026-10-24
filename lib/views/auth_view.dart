import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/views/app_lock_setup_view.dart';
import 'package:self_finance/views/pin_auth_view.dart';

class AuthView extends ConsumerWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(userProvider)
        .when(
          data: (User? data) {
            final User? user = data;
            if (user == null) {
              return const AppLockSetupView();
            } else {
              return const PinAuthView();
            }
          },
          error: (error, _) => Scaffold(
            body: Center(
              child: BodyTwoDefaultText(text: error.toString(), error: true),
            ),
          ),
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
        );
  }
}
