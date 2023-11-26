import 'package:flutter/material.dart';
import 'package:self_finance/theme/colors.dart';

snackBarWidget({required BuildContext context, required String message}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      animation: ProxyAnimation(),
      backgroundColor: getPrimaryColor,
      content: Row(
        children: [
          Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    ),
  );
}
