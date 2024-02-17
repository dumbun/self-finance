import 'package:flutter/material.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/theme/app_colors.dart';

snackBarWidget({required BuildContext context, required String message}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      showCloseIcon: true,
      backgroundColor: AppColors.getPrimaryColor,
      content: Row(
        children: [
          BodyOneDefaultText(
            text: message,
            bold: true,
          ),
        ],
      ),
    ),
  );
}
