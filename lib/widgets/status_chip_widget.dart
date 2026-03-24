import 'package:flutter/material.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';

class StatusChipWidget extends StatelessWidget {
  const StatusChipWidget({
    super.key,
    required this.status,
    this.smallText = false,
  });

  final bool smallText;
  final String status;

  @override
  Widget build(BuildContext context) {
    final bool isActive = status == Constant.active;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.getGreenColor.withAlpha(30)
            : AppColors.getErrorColor.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: smallText
          ? BodySmallText(
              text: isActive ? 'Active' : 'Inactive',
              bold: true,
              color: isActive
                  ? AppColors.getGreenColor
                  : AppColors.getErrorColor,
            )
          : BodyTwoDefaultText(
              text: isActive ? 'Active' : 'Inactive',
              bold: true,
              color: isActive
                  ? AppColors.getGreenColor
                  : AppColors.getErrorColor,
            ),
    );
  }
}
