import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/theme/app_colors.dart';

class PinInputWidget extends StatelessWidget {
  const PinInputWidget({
    super.key,
    required this.pinController,
    required this.obscureText,
    this.validator,
    this.readOnly = false,
  });

  final TextEditingController pinController;
  final bool obscureText;
  final String? Function(String?)? validator;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color(0xFF2196F3);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);

    final defaultPinTheme = PinTheme(
      width: 30.sp,
      height: 30.sp,
      textStyle: TextStyle(fontSize: 22.sp, color: AppColors.getPrimaryColor),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.sp),
        border: Border.all(color: AppColors.getPrimaryColor),
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Pinput(
        toolbarEnabled: true,
        errorTextStyle: const TextStyle(
          fontFamily: "hell",
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
          color: AppColors.getErrorColor,
        ),
        readOnly: readOnly,
        obscureText: obscureText,
        length: 4,
        closeKeyboardWhenCompleted: true,
        keyboardType: TextInputType.number,
        focusedPinTheme: defaultPinTheme.copyWith(
          decoration: defaultPinTheme.decoration!.copyWith(
            borderRadius: BorderRadius.circular(8.sp),
            border: Border.all(color: focusedBorderColor),
          ),
        ),
        submittedPinTheme: defaultPinTheme.copyWith(
          decoration: defaultPinTheme.decoration!.copyWith(
            color: fillColor,
            borderRadius: BorderRadius.circular(19.sp),
            border: Border.all(color: focusedBorderColor),
          ),
        ),
        controller: pinController,
        validator:
            validator ??
            (String? value) {
              if (value == null || value.isEmpty || value == "") {
                return 'Please enter a valid value';
              }
              return null;
            },
        defaultPinTheme: defaultPinTheme,
        separatorBuilder: (int index) => SizedBox(width: 12.sp),
        hapticFeedbackType: HapticFeedbackType.lightImpact,
      ),
    );
  }
}
