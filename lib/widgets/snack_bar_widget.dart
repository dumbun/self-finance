import 'package:flutter/material.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';

class SnackBarWidget {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
  snackBarWidget({required BuildContext context, required String message}) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Durations.short3,
        showCloseIcon: true,
        backgroundColor: AppColors.getPrimaryColor,
        content: Row(children: [BodyTwoDefaultText(text: message, bold: true)]),
      ),
    );
  }
}
