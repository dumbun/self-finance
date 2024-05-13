import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/auth/auth.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/views/dashboard_view.dart';
import 'package:self_finance/views/pin_auth_view.dart';
import 'package:self_finance/views/terms_and_conditions.dart';

class AuthView extends ConsumerStatefulWidget {
  const AuthView({super.key});

  @override
  ConsumerState<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends ConsumerState<AuthView> {
  bool _isAuthenticated = false;

  @override
  void initState() {
    _authenticateWithBiometrics();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(asyncUserProvider).when(
          data: (List users) {
            if (users.isNotEmpty) {
              return _isAuthenticated ? const DashboardView() : const PinAuthView();
            } else {
              return const TermsAndConditons();
            }
          },
          loading: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
          error: (error, stackTrace) => const Center(
            child: BodyOneDefaultText(
              text: Constant.errorUserFetch,
            ),
          ),
        );
  }

  void _authenticateWithBiometrics() {
    LocalAuthenticator.authenticate().then((value) {
      setState(() {
        _isAuthenticated = value;
      });
    });
  }
}
