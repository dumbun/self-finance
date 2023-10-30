import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/views/dashboard_view.dart';
import 'package:self_finance/views/pin_auth_view.dart';

class AuthView extends StatefulWidget {
  const AuthView({Key? key, required this.user}) : super(key: key);
  final User user;

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
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isAuthenticated ? DashboardView(user: widget.user) : PinAuthView(user: widget.user);
  }
}
