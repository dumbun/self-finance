import 'package:material_ui/material_ui.dart';
import 'package:pinput/pinput.dart';
import 'package:self_finance/core/theme/app_colors.dart';

class PinInputWidget extends StatelessWidget {
  const PinInputWidget({
    super.key,
    required this.pinController,
    required this.obscureText,
    this.validator,
    this.readOnly = false,
    this.length = 4,
    this.onCompleted,
    this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController pinController;
  final bool obscureText;
  final String? Function(String?)? validator;
  final bool readOnly;
  final int length;
  final void Function(String)? onCompleted;
  final void Function(String)? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color(0xFF2196F3);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);

    final double pinWidth = length > 4 ? 42.0 : 54.0;
    final double pinHeight = length > 4 ? 48.0 : 54.0;
    final double separatorWidth = length > 4 ? 8.0 : 16.0;

    final defaultPinTheme = PinTheme(
      width: pinWidth,
      height: pinHeight,
      textStyle: TextStyle(
        fontSize: length > 4 ? 22 : 26,
        color: AppColors.getPrimaryColor,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getPrimaryColor),
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Pinput(
        length: length,
        autofocus: autofocus,
        onCompleted: onCompleted,
        onChanged: onChanged,
        errorTextStyle: const TextStyle(
          fontFamily: "hell",
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
          color: AppColors.getErrorColor,
        ),
        readOnly: readOnly,
        obscureText: obscureText,
        focusedPinTheme: defaultPinTheme.copyWith(
          decoration: defaultPinTheme.decoration!.copyWith(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: focusedBorderColor),
          ),
        ),
        submittedPinTheme: defaultPinTheme.copyWith(
          decoration: defaultPinTheme.decoration!.copyWith(
            color: fillColor,
            borderRadius: BorderRadius.circular(19),
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
        separatorBuilder: (int index) => SizedBox(width: separatorWidth),
        hapticFeedbackType: HapticFeedbackType.lightImpact,
      ),
    );
  }
}
