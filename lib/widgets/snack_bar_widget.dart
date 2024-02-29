import 'package:flutter/material.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/theme/app_colors.dart';

class SnackBarWidget {
  static snackBarWidget({required BuildContext context, required String message}) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        showCloseIcon: true,
        backgroundColor: AppColors.getPrimaryColor,
        content: Row(
          children: [
            BodyTwoDefaultText(
              text: message,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}
