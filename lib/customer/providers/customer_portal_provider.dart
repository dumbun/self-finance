import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/customer/models/customer_portal_models.dart';
import 'package:self_finance/customer/services/customer_portal_service.dart';

class CustomerPortalAuthState {
  final bool isLoading;
  final bool isOtpSent;
  final String? sessionId;
  final String? verificationId;
  final int? resendToken;
  final bool isAutomated;
  final int codeLength;
  final String? customerName;
  final String? portalToken;
  final String? phoneNumber;
  final String? otpCodeForDebug;
  final String? errorMessage;
  final int? remainingAttempts;

  const CustomerPortalAuthState({
    this.isLoading = false,
    this.isOtpSent = false,
    this.sessionId,
    this.verificationId,
    this.resendToken,
    this.isAutomated = false,
    this.codeLength = 4,
    this.customerName,
    this.portalToken,
    this.phoneNumber,
    this.otpCodeForDebug,
    this.errorMessage,
    this.remainingAttempts,
  });

  bool get isAuthenticated => portalToken != null && portalToken!.isNotEmpty;

  CustomerPortalAuthState copyWith({
    bool? isLoading,
    bool? isOtpSent,
    String? sessionId,
    String? verificationId,
    int? resendToken,
    bool? isAutomated,
    int? codeLength,
    String? customerName,
    String? portalToken,
    String? phoneNumber,
    String? otpCodeForDebug,
    String? errorMessage,
    int? remainingAttempts,
    bool clearError = false,
  }) {
    return CustomerPortalAuthState(
      isLoading: isLoading ?? this.isLoading,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      sessionId: sessionId ?? this.sessionId,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      isAutomated: isAutomated ?? this.isAutomated,
      codeLength: codeLength ?? this.codeLength,
      customerName: customerName ?? this.customerName,
      portalToken: portalToken ?? this.portalToken,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpCodeForDebug: otpCodeForDebug ?? this.otpCodeForDebug,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      remainingAttempts: remainingAttempts ?? this.remainingAttempts,
    );
  }
}

class CustomerPortalAuthNotifier extends Notifier<CustomerPortalAuthState> {
  @override
  CustomerPortalAuthState build() {
    _checkSavedSession();
    return const CustomerPortalAuthState(isLoading: true);
  }

  Future<void> _checkSavedSession() async {
    try {
      final token = await CustomerPortalService.getSavedToken();
      final phone = await CustomerPortalService.getSavedPhoneNumber();
      if (token != null && phone != null) {
        state = CustomerPortalAuthState(
          portalToken: token,
          phoneNumber: phone,
        );
        return;
      }
    } catch (_) {}
    state = const CustomerPortalAuthState();
  }

  /// Sets state when automated SMS OTP has been dispatched via Firebase Auth.
  void setAutomatedOtpSent({
    required String verificationId,
    required String customerName,
    required String phoneNumber,
    int? resendToken,
  }) {
    state = state.copyWith(
      isLoading: false,
      isOtpSent: true,
      verificationId: verificationId,
      customerName: customerName,
      phoneNumber: phoneNumber,
      resendToken: resendToken,
      isAutomated: true,
      codeLength: 6,
      clearError: true,
    );
  }

  /// Sets loading state during authentication actions.
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// Sets error message in state.
  void setError(String message) {
    state = state.copyWith(isLoading: false, errorMessage: message);
  }

  /// Requests a 4-digit OTP for the given phone number (fallback/test mode).
  Future<bool> requestOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final response = await CustomerPortalService.requestOtp(phoneNumber);

    if (response.success && response.sessionId != null) {
      state = state.copyWith(
        isLoading: false,
        isOtpSent: true,
        sessionId: response.sessionId,
        customerName: response.customerName,
        phoneNumber: phoneNumber,
        otpCodeForDebug: response.otpCode,
        isAutomated: false,
        codeLength: 4,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Failed to send OTP code.',
      );
      return false;
    }
  }

  /// Verifies entered OTP code (handles both automated Phone Auth and Firestore sessions).
  Future<bool> verifyOtp(String pin) async {
    if (state.isAutomated && state.verificationId != null) {
      state = state.copyWith(isLoading: true, clearError: true);
      final response = await CustomerPortalService.verifyPhoneAuthOtp(
        verificationId: state.verificationId!,
        smsCode: pin,
        phoneNumber: state.phoneNumber ?? '',
      );

      if (response.success && response.portalToken != null) {
        state = state.copyWith(
          isLoading: false,
          portalToken: response.portalToken,
          phoneNumber: response.phoneNumber,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message ?? 'Invalid verification code.',
        );
        return false;
      }
    }

    final sessionId = state.sessionId;
    if (sessionId == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    final response = await CustomerPortalService.verifyOtp(
      sessionId: sessionId,
      enteredOtp: pin,
    );

    if (response.success && response.portalToken != null) {
      state = state.copyWith(
        isLoading: false,
        portalToken: response.portalToken,
        phoneNumber: response.phoneNumber,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Invalid OTP code.',
        remainingAttempts: response.remainingAttempts,
      );
      return false;
    }
  }

  /// Logs out of customer portal.
  Future<void> signOut() async {
    await CustomerPortalService.clearSession();
    state = const CustomerPortalAuthState();
  }

  /// Clears any visible error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final customerPortalAuthProvider =
    NotifierProvider<CustomerPortalAuthNotifier, CustomerPortalAuthState>(
  CustomerPortalAuthNotifier.new,
);

/// Fetches dashboard data for the authenticated customer.
final customerPortalDataProvider =
    FutureProvider.autoDispose<CustomerPortalData?>((ref) async {
  final authState = ref.watch(customerPortalAuthProvider);
  final token = authState.portalToken;
  if (token == null || token.isEmpty) return null;

  return await CustomerPortalService.fetchPortalData(token);
});
