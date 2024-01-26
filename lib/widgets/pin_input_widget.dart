import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/theme/colors.dart';

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
    const borderColor = Color(0xFF90CAF9);

    final defaultPinTheme = PinTheme(
      width: 30.sp,
      height: 30.sp,
      textStyle: TextStyle(
        fontSize: 22.sp,
        // color: const Color.fromRGBO(30, 60, 87, 1),
        color: AppColors.getPrimaryColor,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19.sp),
        border: Border.all(color: borderColor),
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Pinput(
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
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty || value == "") {
                return 'Please enter a valid value';
              }
              return null;
            },
        defaultPinTheme: defaultPinTheme,
        separatorBuilder: (index) => SizedBox(width: 8.sp),
        hapticFeedbackType: HapticFeedbackType.lightImpact,
      ),
    );
  }
}
