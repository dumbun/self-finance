import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/views/dashboard_view.dart';
import 'package:self_finance/views/pin_auth_view.dart';
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
      final canCheckBiometrics = await auth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        setState(() {
          _isAuthenticated = false;
        });
        return;
      }

      final availableBiometrics = await auth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty || Platform.isMacOS) {
        setState(() {
          _isAuthenticated = false;
        });
        return;
      }

      final authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint (or face or whatever) to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      if (authenticated) {
        setState(() {
          _isAuthenticated = true;
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _isAuthenticated = false;
      });
      _showAlert(e);
    }
  }

  void _showAlert(PlatformException e) {
    AlertDilogs.alertDialogWithOneAction(context, error, e.code);
  }

  @override
  Widget build(BuildContext context) {
    return _isAuthenticated ? const DashboardView() : const PinAuthView();
  }
}
