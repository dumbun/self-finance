import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';

class StatusChipWidget extends StatelessWidget {
  final String status;
  const StatusChipWidget(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final bool isActive = status == Constant.active;

    return Container(
      key: UniqueKey(),
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.getGreenColor.withAlpha(30)
            : AppColors.getErrorColor.withAlpha(30),
        borderRadius: BorderRadius.circular(20.sp),
      ),
      child: BodyTwoDefaultText(
        text: isActive ? 'Active' : 'Inactive',
        bold: true,
        color: isActive ? AppColors.getGreenColor : AppColors.getErrorColor,
      ),
    );
  }
}
