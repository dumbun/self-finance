import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/auth/auth.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/fonts/strong_heading_one_text.dart';
import 'package:self_finance/core/utility/preferences_helper.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/widgets/biometric_button_widget.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/pin_input_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';

class PinAuthView extends StatefulWidget {
  const PinAuthView({super.key, this.scanBioMetrics = true});

  final bool scanBioMetrics;
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

  @override
  void initState() {
    if (widget.scanBioMetrics) _handleBiometric();
    super.initState();
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
      final bool res = await PreferencesHelper.isBiometrics();
      if (res) {
        final bool ok = await LocalAuthenticator.authenticate();
        if (ok) _goToDashboard();
      }
    } finally {
      _isSubmitting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Consumer(
              builder: (context, ref, child) => ref
                  .watch(userProvider)
                  .when(
                    loading: () => const CircularProgressIndicator.adaptive(),
                    error: (_, _) =>
                        const BodyTwoDefaultText(text: Constant.errorUserFetch),
                    data: (User? user) {
                      if (user == null) {
                        return const BodyTwoDefaultText(
                          text: Constant.errorUserFetch,
                        );
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (user.profilePicture.isNotEmpty)
                            CircularImageWidget(
                              customeSize: 120,
                              imageData: user.profilePicture,
                              titile: user.userName,
                            )
                          else
                            const DefaultUserImage(height: 120),

                          const SizedBox(height: 20),

                          const StrongHeadingOne(
                            bold: true,
                            text: Constant.enterYourAppPin,
                          ),

                          const SizedBox(height: 20),

                          PinInputWidget(
                            pinController: _pinController,
                            obscureText: true,
                            validator: (String? value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return Constant.enterYourAppPin;
                              if (v != user.userPin) {
                                return Constant.enterCorrectPin;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          Padding(
                            padding: const EdgeInsetsGeometry.only(
                              left: 22,
                              right: 22,
                            ),
                            child: RoundedCornerButton(
                              text: Constant.login,
                              onPressed: () =>
                                  _handlePinSubmit(expectedPin: user.userPin),
                            ),
                          ),

                          const SizedBox(height: 20),

                          BiometricButtonWidget(onPressed: _handleBiometric),
                        ],
                      );
                    },
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
