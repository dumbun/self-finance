import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Exception thrown when cloud verification cannot be performed.
class CloudOtpException implements Exception {
  final String message;
  const CloudOtpException(this.message);

  @override
  String toString() => message;
}

/// Result returned from Supabase server OTP verification.
class CloudVerificationResult {
  final bool success;
  final String? verificationToken;
  final String? error;
  final String? message;
  final int? remainingAttempts;

  const CloudVerificationResult({
    required this.success,
    this.verificationToken,
    this.error,
    this.message,
    this.remainingAttempts,
  });
}

/// Represents an active OTP verification session.
class OtpSession {
  final String? verificationId;
  final String code;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String phoneNumber;
  final String customerName;
  final double amount;
  final bool isCloudVerified;

  OtpSession({
    this.verificationId,
    required this.code,
    required this.createdAt,
    required this.expiresAt,
    required this.phoneNumber,
    required this.customerName,
    required this.amount,
    this.isCloudVerified = false,
  });

  /// True if the OTP has passed its 5-minute validity window.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Verifies an entered PIN against this session's OTP code.
  bool verify(String input) {
    if (isExpired) return false;
    return input.trim() == code;
  }
}

/// Service handling OTP generation, expiration, and SMS delivery.
class OtpService {
  /// Standard validity duration for financial confirmation OTP (5 minutes).
  static const Duration otpValidityDuration = Duration(minutes: 5);

  /// Cooldown duration between resend attempts in seconds.
  static const int resendCooldownSeconds = 60;

  /// Generates a cryptographically secure numeric OTP string of given length.
  static String generateOtp({int digits = 4}) {
    final Random random = Random.secure();
    final int min = pow(10, digits - 1).toInt();
    final int max = pow(10, digits).toInt() - 1;
    final int code = min + random.nextInt(max - min + 1);
    return code.toString();
  }

  /// Creates a local [OtpSession] (used in test/debug environments).
  static OtpSession createSession({
    required String customerName,
    required String phoneNumber,
    required double amount,
    int digits = 4,
  }) {
    final String code = generateOtp(digits: digits);
    final DateTime now = DateTime.now();
    return OtpSession(
      code: code,
      createdAt: now,
      expiresAt: now.add(otpValidityDuration),
      phoneNumber: phoneNumber,
      customerName: customerName,
      amount: amount,
    );
  }

  /// Requests a cryptographically generated & hashed OTP session from Supabase.
  static Future<OtpSession> requestCloudOtp({
    required String customerName,
    required String phoneNumber,
    required double amount,
  }) async {
    if (Utility.isSupabaseInitialized &&
        Supabase.instance.client.auth.currentSession != null) {
      try {
        final dynamic response = await Supabase.instance.client.rpc(
          'request_loan_otp',
          params: {
            'p_customer_number': phoneNumber,
            'p_customer_name': customerName,
            'p_loan_amount': amount,
          },
        );

        if (response is Map) {
          final map = Map<String, dynamic>.from(response);
          final String verificationId = map['verification_id'] as String;
          final String otpCode = map['otp_code'] as String;
          final DateTime expiresAt = DateTime.tryParse(
                map['expires_at'] as String? ?? '',
              ) ??
              DateTime.now().add(otpValidityDuration);

          return OtpSession(
            verificationId: verificationId,
            code: otpCode,
            createdAt: DateTime.now(),
            expiresAt: expiresAt,
            phoneNumber: phoneNumber,
            customerName: customerName,
            amount: amount,
            isCloudVerified: true,
          );
        }
      } catch (e) {
        debugPrint('Supabase request_loan_otp error: $e');
        throw CloudOtpException(
          'Failed to generate secure OTP from server: $e',
        );
      }
    }

    // In debug/test mode when Supabase is not logged in
    if (kDebugMode) {
      return createSession(
        customerName: customerName,
        phoneNumber: phoneNumber,
        amount: amount,
      );
    }

    throw const CloudOtpException(
      'Active internet connection and Supabase login required for customer OTP verification.',
    );
  }

  /// Verifies the entered OTP code against Supabase server-side hash.
  static Future<CloudVerificationResult> verifyCloudOtp({
    required OtpSession session,
    required String enteredPin,
  }) async {
    if (session.isCloudVerified && session.verificationId != null) {
      try {
        final dynamic response = await Supabase.instance.client.rpc(
          'verify_loan_otp',
          params: {
            'p_verification_id': session.verificationId,
            'p_entered_otp': enteredPin.trim(),
          },
        );

        if (response is Map) {
          final map = Map<String, dynamic>.from(response);
          return CloudVerificationResult(
            success: map['success'] == true,
            verificationToken: map['verification_token'] as String?,
            error: map['error'] as String?,
            message: map['message'] as String?,
            remainingAttempts: map['remaining_attempts'] as int?,
          );
        }
      } catch (e) {
        debugPrint('Supabase verify_loan_otp error: $e');
        return CloudVerificationResult(
          success: false,
          error: 'SERVER_ERROR',
          message: e.toString(),
        );
      }
    }

    // Local / debug fallback
    final bool match = session.verify(enteredPin);
    return CloudVerificationResult(
      success: match,
      verificationToken: match ? 'local-verified-token' : null,
      error: match ? null : 'INVALID_OTP',
      message: match ? null : 'Invalid OTP code',
    );
  }

  /// Sends the OTP via device SMS launcher.
  static Future<bool> sendOtp({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      return await Utility.sendSms(
        phoneNumber: phoneNumber,
        body: message,
      );
    } catch (e) {
      debugPrint('OtpService.sendOtp failed: $e');
      return false;
    }
  }
}
