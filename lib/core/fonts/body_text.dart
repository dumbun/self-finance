import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/theme/app_colors.dart';

class BodyOneDefaultText extends StatelessWidget {
  final String text;
  final bool bold;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool error;
  final bool whiteColor;
  final Color? color;

  const BodyOneDefaultText({
    super.key,
    required this.text,
    this.textAlign,
    this.bold = false,
    this.error = false,
    this.whiteColor = false,
    this.maxLines,
    this.overflow,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: true,
      style: TextStyle(
        fontWeight: bold ? FontWeight.bold : FontWeight.w400,
        fontSize: 18.sp,
        fontFamily: "hell",
        color: _getColor(context),
      ),
    );
  }

  Color? _getColor(BuildContext context) {
    if (error) {
      return AppColors.getErrorColor;
    } else if (whiteColor) {
      return AppColors.getBackgroundColor;
    } else {
      return color;
    }
  }
}
