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
  final List<User> userDate;
  const PinAuthView({super.key, required this.userDate});

  @override
  State<PinAuthView> createState() => _PinAuthViewState();
}

class _PinAuthViewState extends State<PinAuthView> {
  final TextEditingController _pinController = TextEditingController();

  // Small cache: avoid repeated widget.userDate.first lookups + string checks
  late final User _user;

  // Avoid double navigation / repeated submit
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _user = widget.userDate.first;
  }

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

  void _handlePinSubmit() {
    if (_isSubmitting) return;

    final entered = _pinController.text.trim();
    if (entered.isEmpty) return;

    _isSubmitting = true;
    try {
      if (entered == _user.userPin) {
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
    final String profilePic = _user.profilePicture.trim();
    final bool hasProfilePic = profilePic.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Center(
          // Center avoids Stack/Align overhead; simpler tree
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.all(12.sp),
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

                // Keep validator cheap: no navigation inside validator
                PinInputWidget(
                  pinController: _pinController,
                  obscureText: true,
                  validator: (String? value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return Constant.enterYourAppPin;
                    if (v != _user.userPin) return Constant.enterCorrectPin;
                    return null;
                  },
                ),

                SizedBox(height: 20.sp),

                RoundedCornerButton(
                  text: Constant.login,
                  onPressed: _handlePinSubmit,
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
