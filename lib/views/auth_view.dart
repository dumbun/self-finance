import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:self_finance/backend/user_db.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/views/dashboard_view.dart';
import 'package:self_finance/views/pin_auth_view.dart';
import 'package:self_finance/views/terms_and_conditions.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _authenticateWithBiometrics();
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        setState(() => _isAuthenticated = false);
        return;
      }

      final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        setState(() => _isAuthenticated = false);
        return;
      }

      final bool authenticated = await _performBiometricAuthentication();

      if (authenticated) {
        setState(() => _isAuthenticated = true);
      }
    } on PlatformException catch (e) {
      setState(() => _isAuthenticated = false);
      _showAlert(e);
    }
  }

  Future<bool> _performBiometricAuthentication() async {
    return await auth.authenticate(
      localizedReason: 'Scan your fingerprint (or face or whatever) to authenticate',
      options: const AuthenticationOptions(
        stickyAuth: true,
        useErrorDialogs: true,
        sensitiveTransaction: true,
      ),
    );
  }

  void _showAlert(PlatformException e) {
    AlertDilogs.alertDialogWithOneAction(context, error, e.code);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: UserBackEnd.fetchIDOneUser(),
      builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error fetching user data: ${snapshot.error}'),
            ),
          );
        } else {
          List<User> users = snapshot.data ?? [];

          if (users.isNotEmpty) {
            return _isAuthenticated ? const DashboardView() : const PinAuthView();
          } else {
            return const TermsAndConditons();
          }
        }
      },
    );
  }
}
