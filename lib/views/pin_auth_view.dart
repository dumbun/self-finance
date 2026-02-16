import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/auth/auth.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/strong_heading_one_text.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/pin_input_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';

class PinAuthView extends StatefulWidget {
  const PinAuthView({super.key, required this.userDate});
  final User userDate;
  @override
  State<PinAuthView> createState() => _PinAuthViewState();
}

class _PinAuthViewState extends State<PinAuthView> {
  final TextEditingController _pinController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _goToDashboard() {
    if (!mounted) return;
    Routes.navigateToDashboard(context: context);
  }

  void _clearPin() {
    if (_pinController.text.isEmpty) return;
    _pinController.clear();
  }

  void _handlePinSubmit({required String expectedPin}) {
    if (_isSubmitting) return;

    final entered = _pinController.text.trim();
    if (entered.isEmpty) return;

    _isSubmitting = true;
    try {
      if (entered == expectedPin) {
        _goToDashboard();
      } else {
        _clearPin();
      }
    } finally {
      _isSubmitting = false;
    }
  }

  Future<void> _handleBiometric() async {
    if (_isSubmitting) return;

    _isSubmitting = true;
    try {
      final bool ok = await LocalAuthenticator.authenticate();
      if (ok) _goToDashboard();
    } finally {
      _isSubmitting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final User user = widget.userDate;
    final String profilePic = user.profilePicture.trim();
    final bool hasProfilePic = profilePic.isNotEmpty;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasProfilePic)
                  CircularImageWidget(
                    imageData: profilePic,
                    titile: Constant.userProfileTag,
                  )
                else
                  DefaultUserImage(height: 42.sp),

                SizedBox(height: 20.sp),

                const StrongHeadingOne(
                  bold: true,
                  text: Constant.enterYourAppPin,
                ),

                SizedBox(height: 20.sp),

                PinInputWidget(
                  pinController: _pinController,
                  obscureText: true,
                  validator: (String? value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return Constant.enterYourAppPin;
                    if (v != user.userPin) return Constant.enterCorrectPin;
                    return null;
                  },
                ),

                SizedBox(height: 20.sp),

                Padding(
                  padding: EdgeInsetsGeometry.only(left: 22.sp, right: 22.sp),
                  child: RoundedCornerButton(
                    text: Constant.login,
                    onPressed: () =>
                        _handlePinSubmit(expectedPin: user.userPin),
                  ),
                ),

                SizedBox(height: 20.sp),

                IconButton(
                  onPressed: _handleBiometric,
                  icon: Icon(
                    Icons.fingerprint,
                    color: AppColors.getPrimaryColor,
                    size: 32.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
