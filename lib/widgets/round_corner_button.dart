import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/theme/colors.dart';

class RoundedCornerButton extends StatelessWidget {
  const RoundedCornerButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  final String text;
  final void Function() onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return icon != null
        ? SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.getPrimaryColor),
              icon: Icon(icon),
              onPressed: onPressed,
              label: Padding(
                padding: EdgeInsets.all(14.sp),
                child: BodyOneDefaultText(
                  whiteColor: true,
                  text: text,
                  bold: true,
                ),
              ),
            ),
          )
        : SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.getPrimaryColor),
                onPressed: onPressed,
                child: Padding(
                  padding: EdgeInsets.all(14.sp),
                  child: BodyOneDefaultText(
                    whiteColor: true,
                    text: text,
                    bold: true,
                  ),
                )),
          );
  }
}
