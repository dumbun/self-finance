import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/customer/models/customer_portal_models.dart';
import 'package:self_finance/customer/services/customer_portal_service.dart';

class CustomerPortalAuthState {
  final bool isLoading;
  final bool isOtpSent;
  final String? sessionId;
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

  /// Requests a 4-digit OTP for the given phone number.
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

  /// Verifies entered OTP code.
  Future<bool> verifyOtp(String pin) async {
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
      ref.invalidate(customerPortalDataProvider);
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
    ref.invalidate(customerPortalDataProvider);
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
