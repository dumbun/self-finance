import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/views/pin_auth_view.dart';
import 'package:self_finance/views/terms_and_conditions.dart';

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
              return const TermsAndConditons();
            } else {
              return PinAuthView(userDate: user);
            }
          },
          error: (error, stackTrace) => const Scaffold(
            body: Center(
              child: BodyTwoDefaultText(
                text: Constant.errorUserFetch,
                error: true,
              ),
            ),
          ),
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
        );
  }
}
