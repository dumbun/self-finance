import 'package:flutter/material.dart';
import 'package:self_finance/views/pin_creating_view.dart';

class Routes {
  final BuildContext context;
  const Routes({required this.context});

  static navigateToPinCreationView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PinCreatingView(),
      ),
    );
  }
}
