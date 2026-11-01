import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/otp_service.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/pin_input_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

/// Modal bottom sheet that prompts the user to enter the OTP sent to the customer
/// before a loan or transaction can be finalized.
class CustomerOtpVerificationBottomSheet extends StatefulWidget {
  final String customerName;
  final String phoneNumber;
  final double loanAmount;

  const CustomerOtpVerificationBottomSheet({
    super.key,
    required this.customerName,
    required this.phoneNumber,
    required this.loanAmount,
  });

  /// Displays the OTP verification bottom sheet and returns the verification token if verified,
  /// or `null` if cancelled or dismissed.
  static Future<String?> show({
    required BuildContext context,
    required String customerName,
    required String phoneNumber,
    required double loanAmount,
  }) async {
    final String? result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CustomerOtpVerificationBottomSheet(
        customerName: customerName,
        phoneNumber: phoneNumber,
        loanAmount: loanAmount,
      ),
    );
    return result;
  }

  @override
  State<CustomerOtpVerificationBottomSheet> createState() =>
      _CustomerOtpVerificationBottomSheetState();
}

class _CustomerOtpVerificationBottomSheetState
    extends State<CustomerOtpVerificationBottomSheet> {
  final TextEditingController _pinController = TextEditingController();
  OtpSession? _session;

  Timer? _timer;
  int _countdown = OtpService.resendCooldownSeconds;
  String? _errorMessage;
  String? _initError;
  bool _isInitializing = true;
  bool _isVerifying = false;
  int? _resendToken;
  bool _isAutomated = false;
  String? _autoSendStatus;

  @override
  void initState() {
    super.initState();
    _startNewSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _countdown = OtpService.resendCooldownSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

  Future<void> _startNewSession() async {
    setState(() {
      _isInitializing = true;
      _initError = null;
      _errorMessage = null;
      _autoSendStatus = null;
    });

    // Check if Firebase is available for automated Phone Auth
    if (Firebase.apps.isNotEmpty) {
      try {
        await OtpService.sendAutomatedPhoneOtp(
          phoneNumber: widget.phoneNumber,
          resendToken: _resendToken,
          onCodeSent: (String verificationId, int? resendToken) {
            if (!mounted) return;
            final now = DateTime.now();
            final session = OtpSession(
              verificationId: verificationId,
              code: '',
              createdAt: now,
              expiresAt: now.add(OtpService.otpValidityDuration),
              phoneNumber: widget.phoneNumber,
              customerName: widget.customerName,
              amount: widget.loanAmount,
              isCloudVerified: true,
              isAutomated: true,
              codeLength: 6,
              resendToken: resendToken,
            );
            setState(() {
              _session = session;
              _resendToken = resendToken;
              _isAutomated = true;
              _isInitializing = false;
              _autoSendStatus = 'SMS sent automatically to ${widget.phoneNumber}';
            });
            _startTimer();
          },
          onVerificationCompleted: (PhoneAuthCredential credential) async {
            if (!mounted) return;
            if (credential.smsCode != null && credential.smsCode!.isNotEmpty) {
              _pinController.text = credential.smsCode!;
              await _verifyCode(credential.smsCode!);
            }
          },
          onVerificationFailed: (FirebaseAuthException e) {
            debugPrint(
                'Firebase phone verification failed: ${e.message} (code: ${e.code})');
            if (!mounted) return;
            _fallbackToCloudOtp(hint: e.message);
          },
          onCodeAutoRetrievalTimeout: (String verificationId) {
            debugPrint(
                'Firebase phone verification auto retrieval timeout: $verificationId');
          },
        );
        return;
      } catch (e) {
        debugPrint('Automated phone auth exception: $e');
      }
    }

    await _fallbackToCloudOtp();
  }

  Future<void> _fallbackToCloudOtp({String? hint}) async {
    try {
      final OtpSession session = await OtpService.requestCloudOtp(
        customerName: widget.customerName,
        phoneNumber: widget.phoneNumber,
        amount: widget.loanAmount,
      );

      if (!mounted) return;

      setState(() {
        _session = session;
        _isAutomated = false;
        _isInitializing = false;
        if (hint != null) {
          _autoSendStatus =
              'Automated SMS unavailable. Tap "Open SMS App" to send.';
        }
      });

      _startTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _initError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _sendManualSms() async {
    final session = _session;
    if (session == null) return;

    final String formattedAmount = Utility.doubleFormate(widget.loanAmount);
    final String codeToSend = session.code.isNotEmpty ? session.code : '------';
    final String message = context.l10n.otpSmsTemplate(
      formattedAmount,
      codeToSend,
    );

    final bool sent = await OtpService.sendManualSms(
      phoneNumber: widget.phoneNumber,
      message: message,
    );

    if (mounted && sent) {
      SnackBarWidget.snackBarWidget(
        context: context,
        message: context.l10n.otpSentSuccessfully,
      );
    }
  }

  void _handleResend() {
    setState(() {
      _errorMessage = null;
      _pinController.clear();
    });
    _startNewSession();
  }

  Future<void> _verifyCode(String pin) async {
    final session = _session;
    if (_isVerifying || session == null) return;

    final String cleanPin = pin.trim();
    final int requiredLength = session.codeLength;
    if (cleanPin.length != requiredLength) return;

    setState(() => _isVerifying = true);

    if (session.isExpired) {
      setState(() {
        _isVerifying = false;
        _errorMessage = context.l10n.otpExpired;
        _pinController.clear();
      });
      return;
    }

    final CloudVerificationResult result = await OtpService.verifyCloudOtp(
      session: session,
      enteredPin: cleanPin,
    );

    if (!mounted) return;

    if (result.success) {
      Navigator.of(context).pop(result.verificationToken ?? 'verified');
    } else {
      setState(() {
        _isVerifying = false;
        if (result.error == 'MAX_ATTEMPTS') {
          _errorMessage = context.l10n.tooManyOtpAttempts;
        } else if (result.error == 'EXPIRED') {
          _errorMessage = context.l10n.otpExpired;
        } else {
          _errorMessage = result.message ?? context.l10n.invalidOtpCode;
        }
        _pinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final session = _session;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Icon & Dismiss
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.getPrimaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppColors.getPrimaryColor,
                      size: 26,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: l10n.cancel,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Title & Description
              Text(
                l10n.customerOtpVerification,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getPrimaryColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.otpSentMessage(widget.customerName, widget.phoneNumber),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.getLigthGreyColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Loan Amount Summary Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.getLigthGreyColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      size: 18,
                      color: AppColors.getPrimaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${l10n.takenAmount}: ",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    CurrencyWidget(
                      amount: Utility.doubleFormate(widget.loanAmount),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Automated Delivery Status Banner
              if (_autoSendStatus != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isAutomated
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isAutomated
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isAutomated
                            ? Icons.mark_email_read_outlined
                            : Icons.info_outline_rounded,
                        size: 16,
                        color: _isAutomated ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _autoSendStatus!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _isAutomated
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (_isInitializing) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
                Center(
                  child: Text(
                    l10n.generatingOtp,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.getLigthGreyColor,
                    ),
                  ),
                ),
              ] else if (_initError != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.getErrorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.getErrorColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        color: AppColors.getErrorColor,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _initError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.getErrorColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _startNewSession,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(l10n.pleaseTryAgain),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Subheading
                Center(
                  child: Text(
                    session?.codeLength == 6
                        ? "Enter 6-Digit Verification Code"
                        : l10n.enterVerificationCode,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // PIN Input
                Center(
                  child: PinInputWidget(
                    pinController: _pinController,
                    obscureText: false,
                    autofocus: true,
                    length: session?.codeLength ?? 4,
                    onChanged: (_) {
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      } else {
                        setState(() {});
                      }
                    },
                    onCompleted: _verifyCode,
                  ),
                ),

                // Error Message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 16,
                        color: AppColors.getErrorColor,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.getErrorColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // Resend & Open SMS App Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_countdown > 0)
                      Text(
                        l10n.resendOtpIn(_countdown),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.getLigthGreyColor,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _handleResend,
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: Text(l10n.resendOtp),
                      ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: _sendManualSms,
                      icon: const Icon(Icons.sms_outlined, size: 16),
                      label: Text(l10n.openSmsApp),
                    ),
                  ],
                ),

                // Debug / Testing Quick Fill (visible in debug mode)
                if (kDebugMode && session != null && session.code.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      _pinController.text = session.code;
                      Utility.copyToClipboard(text: session.code);
                      _verifyCode(session.code);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        border: Border.all(color: Colors.amber.shade700, width: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bug_report_outlined,
                            size: 14,
                            color: Colors.amber.shade900,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Test Mode: Auto-verify server OTP (${session.code})",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Primary Verify Button
                if (_isVerifying)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  )
                else
                  RoundedCornerButton(
                    text: l10n.verifyAndConfirm,
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: _pinController.text.trim().length ==
                            (session?.codeLength ?? 4)
                        ? () => _verifyCode(_pinController.text.trim())
                        : null,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
