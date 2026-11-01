import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/otp_service.dart';
import 'package:self_finance/customer/providers/customer_portal_provider.dart';
import 'package:self_finance/customer/services/customer_portal_service.dart';
import 'package:self_finance/customer/views/customer_dashboard_view.dart';
import 'package:self_finance/models/country_model.dart';
import 'package:self_finance/widgets/country_code_picker_widget.dart';
import 'package:self_finance/widgets/pin_input_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

class CustomerLoginView extends ConsumerStatefulWidget {
  const CustomerLoginView({super.key});

  @override
  ConsumerState<CustomerLoginView> createState() => _CustomerLoginViewState();
}

class _CustomerLoginViewState extends ConsumerState<CustomerLoginView> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  Country _selectedCountry = Country.defaultCountry;

  Timer? _resendTimer;
  int _countdown = 60;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _resendTimer?.cancel();
    setState(() => _countdown = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _fullPhoneNumber {
    return '${_selectedCountry.dialCode} ${_phoneController.text.trim()}';
  }

  Future<void> _handleSendOtp() async {
    final rawPhone = _phoneController.text.trim();
    if (rawPhone.isEmpty || rawPhone.length < 6) {
      SnackBarWidget.snackBarWidget(
        context: context,
        message: context.l10n.pleaseEnterTheNumber,
      );
      return;
    }

    final notifier = ref.read(customerPortalAuthProvider.notifier);
    final currentAuthState = ref.read(customerPortalAuthProvider);
    notifier.setLoading(true);

    try {
      await CustomerPortalService.requestPhoneAuthOtp(
        phoneNumber: _fullPhoneNumber,
        resendToken: currentAuthState.resendToken,
        onCodeSent: (verificationId, resendToken, customerName) {
          if (!mounted) return;
          notifier.setAutomatedOtpSent(
            verificationId: verificationId,
            customerName: customerName,
            phoneNumber: _fullPhoneNumber,
            resendToken: resendToken,
          );
          _startTimer();
          final greeting = customerName.isNotEmpty ? ' $customerName' : '';
          SnackBarWidget.snackBarWidget(
            context: context,
            message: '${context.l10n.otpSentSuccessfully}$greeting',
          );
        },
        onVerificationCompleted: (PhoneAuthCredential credential) async {
          if (!mounted) return;
          if (credential.smsCode != null && credential.smsCode!.isNotEmpty) {
            _pinController.text = credential.smsCode!;
            await _handleVerifyOtp(credential.smsCode!);
          }
        },
        onVerificationFailed: (FirebaseAuthException e) async {
          if (!mounted) return;
          debugPrint('CustomerPortal Phone Auth failed: ${e.code} - ${e.message}');
          // Fall back to direct OTP session if SMS gateway encounters error
          await _fallbackToSendOtp(fallbackReason: e.message ?? e.code);
        },
        onCodeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('CustomerPortal Auto-retrieval timeout: $verificationId');
        },
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('CustomerPortal send OTP exception: $e');
      await _fallbackToSendOtp(fallbackReason: e.toString());
    }
  }

  Future<void> _fallbackToSendOtp({String? fallbackReason}) async {
    final success = await ref
        .read(customerPortalAuthProvider.notifier)
        .requestOtp(_fullPhoneNumber);

    if (mounted && success) {
      _startTimer();
      final authState = ref.read(customerPortalAuthProvider);
      final customerName = authState.customerName ?? '';
      final greeting = customerName.isNotEmpty ? ' $customerName' : '';
      SnackBarWidget.snackBarWidget(
        context: context,
        message: '${context.l10n.otpSentSuccessfully}$greeting',
      );
    }
  }

  Future<void> _handleVerifyOtp(String pin) async {
    final cleanPin = pin.trim();
    final authState = ref.read(customerPortalAuthProvider);
    if (cleanPin.length != authState.codeLength) return;

    final success = await ref
        .read(customerPortalAuthProvider.notifier)
        .verifyOtp(cleanPin);

    if (mounted && success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const CustomerDashboardView(),
        ),
      );
    }
  }

  Future<void> _openSmsApp() async {
    final authState = ref.read(customerPortalAuthProvider);
    final otpCode = authState.otpCodeForDebug ?? '';
    final message = 'Your Self-Finance portal verification code is: $otpCode';

    await OtpService.sendOtp(
      phoneNumber: _fullPhoneNumber,
      message: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final authState = ref.watch(customerPortalAuthProvider);

    return Scaffold(
      appBar: AppBar(
        title: BodyOneDefaultText(
          text: l10n.customerPortal,
          bold: true,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Portal Header Icon
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.getPrimaryColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 36,
                        color: AppColors.getPrimaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title & Subtitle
                  Text(
                    l10n.customerLogin,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.customerLoginSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.getLigthGreyColor,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Phone Number Input Card
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CountryCodePickerWidget(
                        selectedCountry: _selectedCountry,
                        enabled: !authState.isOtpSent && !authState.isLoading,
                        onChanged: (country) {
                          setState(() => _selectedCountry = country);
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          enabled: !authState.isOtpSent && !authState.isLoading,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: l10n.enterMobileNumber,
                            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // If OTP has not been requested yet
                  if (!authState.isOtpSent) ...[
                    if (authState.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    else
                      RoundedCornerButton(
                        text: l10n.sendVerificationCode,
                        icon: Icons.send_rounded,
                        onPressed: _handleSendOtp,
                      ),
                  ] else ...[
                    // OTP Verification Step
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.getPrimaryColor.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (authState.customerName != null &&
                              authState.customerName!.isNotEmpty) ...[
                            Text(
                              'Hello, ${authState.customerName}!',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getPrimaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                          ],
                          Text(
                            authState.isAutomated
                                ? 'Enter 6-digit verification code'
                                : l10n.enterOtpCode,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.getLigthGreyColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),

                          if (authState.isAutomated) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.getPrimaryColor
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.sms_outlined,
                                    size: 16,
                                    color: AppColors.getPrimaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'SMS verification code sent to ${authState.phoneNumber ?? _fullPhoneNumber}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.getPrimaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Dynamic PIN Input Widget (6 digits for SMS, 4 digits for fallback)
                          PinInputWidget(
                            pinController: _pinController,
                            obscureText: false,
                            autofocus: true,
                            length: authState.codeLength,
                            onCompleted: _handleVerifyOtp,
                            onChanged: (pin) {
                              if (pin.length == authState.codeLength) {
                                _handleVerifyOtp(pin);
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          if (authState.isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            )
                          else
                            RoundedCornerButton(
                              text: l10n.verifyAndViewLoans,
                              icon: Icons.check_circle_outline_rounded,
                              onPressed: () =>
                                  _handleVerifyOtp(_pinController.text),
                            ),
                          const SizedBox(height: 12),

                          // Resend & Change Number Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_countdown > 0)
                                Text(
                                  l10n.resendOtpIn(_countdown),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.getLigthGreyColor,
                                  ),
                                )
                              else
                                TextButton(
                                  onPressed: _handleSendOtp,
                                  child: Text(l10n.resendOtp),
                                ),
                              TextButton(
                                onPressed: () {
                                  ref
                                      .read(customerPortalAuthProvider.notifier)
                                      .clearError();
                                  _pinController.clear();
                                  _phoneController.clear();
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const CustomerLoginView(),
                                    ),
                                  );
                                },
                                child: Text(l10n.changeNumber),
                              ),
                            ],
                          ),

                          // Open SMS App button (only for manual/fallback sessions)
                          if (!authState.isAutomated)
                            Center(
                              child: TextButton.icon(
                                onPressed: _openSmsApp,
                                icon: const Icon(Icons.sms_outlined, size: 16),
                                label: Text(l10n.openSmsApp),
                              ),
                            ),

                          // Debug quick-fill chip (visible in debug mode)
                          if (kDebugMode &&
                              authState.otpCodeForDebug != null) ...[
                            const SizedBox(height: 8),
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                _pinController.text =
                                    authState.otpCodeForDebug!;
                                _handleVerifyOtp(authState.otpCodeForDebug!);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  border: Border.all(
                                    color: Colors.amber.shade700,
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.bug_report_outlined,
                                      size: 14,
                                      color: Colors.amber.shade800,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Test OTP: ${authState.otpCodeForDebug} (Tap to fill)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // Error Message Banner
                  if (authState.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.getErrorColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.getErrorColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 18,
                            color: AppColors.getErrorColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authState.errorMessage!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.getErrorColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Back to Lender Login
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.person_outline_rounded, size: 18),
                      label: Text(l10n.backToLenderLogin),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
