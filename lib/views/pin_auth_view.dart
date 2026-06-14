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

class PinAuthView extends ConsumerStatefulWidget {
  const PinAuthView({super.key, this.scanBioMetrics = true});

  final bool scanBioMetrics;

  @override
  ConsumerState<PinAuthView> createState() => _PinAuthViewState();
}

class _PinAuthViewState extends ConsumerState<PinAuthView> {
  late final TextEditingController _pinController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _pinController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scanBioMetrics) {
        _handleBiometric();
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    if (!mounted) return;

    Routes.navigateToDashboard(context: context);
  }

  Future<void> _handlePinSubmit({required String expectedPin}) async {
    if (_isSubmitting) return;

    final String enteredPin = _pinController.text.trim();

    if (enteredPin.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      if (enteredPin == expectedPin) {
        _navigateToDashboard();
        return;
      }

      _pinController.clear();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(Constant.enterCorrectPin)));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleBiometric() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final bool biometricsEnabled = await PreferencesHelper.isBiometrics();

      if (!biometricsEnabled) return;

      final bool authenticated = await LocalAuthenticator.authenticate();

      if (!mounted) return;

      if (authenticated) {
        _navigateToDashboard();
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<User?> userAsync = ref.watch(userProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: userAsync.when(
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
                      text: Constant.enterYourAppPin,
                      bold: true,
                    ),

                    const SizedBox(height: 20),

                    PinInputWidget(
                      pinController: _pinController,
                      obscureText: true,
                      validator: (String? value) {
                        if ((value?.trim().isEmpty ?? true)) {
                          return Constant.enterYourAppPin;
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: RoundedCornerButton(
                        text: _isSubmitting ? "Please wait..." : Constant.login,
                        onPressed: _isSubmitting
                            ? null
                            : () => _handlePinSubmit(expectedPin: user.userPin),
                      ),
                    ),

                    const SizedBox(height: 20),

                    BiometricButtonWidget(
                      onPressed: _isSubmitting ? null : _handleBiometric,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
