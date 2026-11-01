import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/firebase_options.dart';
import 'package:uuid/uuid.dart';

/// Exception thrown when cloud verification cannot be performed.
class CloudOtpException implements Exception {
  final String message;
  const CloudOtpException(this.message);

  @override
  String toString() => message;
}

/// Result returned from server OTP verification.
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
  final bool isAutomated;
  final int codeLength;
  final int? resendToken;

  OtpSession({
    this.verificationId,
    required this.code,
    required this.createdAt,
    required this.expiresAt,
    required this.phoneNumber,
    required this.customerName,
    required this.amount,
    this.isCloudVerified = false,
    this.isAutomated = false,
    this.codeLength = 4,
    this.resendToken,
  });

  /// True if the OTP has passed its validity window.
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

  static FirebaseAuth? _secondaryAuth;

  /// Returns an isolated FirebaseAuth instance for phone verification so that
  /// the lender's primary Google Sign-In session is NEVER affected or overwritten.
  static Future<FirebaseAuth> getSecondaryAuth() async {
    if (_secondaryAuth != null) return _secondaryAuth!;

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    FirebaseApp secondaryApp;
    try {
      secondaryApp = Firebase.app('PhoneVerificationApp');
    } catch (_) {
      secondaryApp = await Firebase.initializeApp(
        name: 'PhoneVerificationApp',
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    _secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
    return _secondaryAuth!;
  }

  /// Formats phone numbers to international E.164 format (e.g. +919876543210)
  /// required by Firebase SMS delivery.
  static String formatToE164(String phone, {String defaultCountryCode = '+91'}) {
    String clean = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (clean.startsWith('+')) {
      return clean;
    }
    if (clean.startsWith('00')) {
      return '+${clean.substring(2)}';
    }
    if (clean.startsWith('0') && clean.length > 10) {
      clean = clean.substring(1);
    }
    final String prefix = defaultCountryCode.startsWith('+')
        ? defaultCountryCode
        : '+$defaultCountryCode';
    return '$prefix$clean';
  }

  /// Dispatches an automated SMS via Firebase Phone Auth to [phoneNumber].
  /// Calls [onCodeSent] when Google successfully queues and dispatches the SMS.
  /// Calls [onVerificationCompleted] if Android auto-retrieves or auto-verifies the SMS.
  /// Calls [onVerificationFailed] if cellular dispatch encounters an error.
  static Future<void> sendAutomatedPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(PhoneAuthCredential credential) onVerificationCompleted,
    required void Function(FirebaseAuthException error) onVerificationFailed,
    required void Function(String verificationId) onCodeAutoRetrievalTimeout,
    int? resendToken,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final String e164 = formatToE164(phoneNumber);
    final auth = await getSecondaryAuth();
    await auth.verifyPhoneNumber(
      phoneNumber: e164,
      timeout: timeout,
      forceResendingToken: resendToken,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    );
  }

  /// Verifies an entered PIN against a Firebase Phone Auth verificationId.
  /// Uses the secondary FirebaseAuth instance, leaving the lender's primary
  /// Google session untouched.
  static Future<CloudVerificationResult> verifyAutomatedPhoneOtp({
    required String verificationId,
    required String enteredPin,
    required String customerNumber,
    required String customerName,
    required double loanAmount,
  }) async {
    final primaryUser =
        Firebase.apps.isNotEmpty ? FirebaseAuth.instance.currentUser : null;
    final String cleanPin = enteredPin.trim();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: cleanPin,
      );

      final auth = await getSecondaryAuth();
      final userCredential = await auth.signInWithCredential(credential);
      await auth.signOut();

      if (userCredential.user != null) {
        final String verificationToken = const Uuid().v4();
        final DateTime now = DateTime.now();

        if (primaryUser != null) {
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(primaryUser.uid)
                .collection('loan_verifications')
                .doc(verificationId)
                .set({
              'id': verificationId,
              'owner_id': primaryUser.uid,
              'customer_number': formatToE164(customerNumber),
              'customer_name': customerName,
              'loan_amount': loanAmount,
              'status': 'VERIFIED',
              'verification_token': verificationToken,
              'method': 'FIREBASE_PHONE_AUTH',
              'verified_at': Timestamp.fromDate(now),
              'created_at': Timestamp.fromDate(now),
              'updated_at': Timestamp.fromDate(now),
            });
          } catch (e) {
            debugPrint('Firestore recording error in verifyAutomatedPhoneOtp: $e');
          }
        }

        return CloudVerificationResult(
          success: true,
          verificationToken: verificationToken,
          message: 'Phone verified successfully via automated SMS.',
        );
      } else {
        return const CloudVerificationResult(
          success: false,
          error: 'INVALID_OTP',
          message: 'Invalid verification code.',
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(
          'Firebase verifyAutomatedPhoneOtp error: ${e.code} - ${e.message}');
      if (e.code == 'invalid-verification-code') {
        return const CloudVerificationResult(
          success: false,
          error: 'INVALID_OTP',
          message: 'Invalid verification code. Please check and try again.',
        );
      } else if (e.code == 'session-expired') {
        return const CloudVerificationResult(
          success: false,
          error: 'EXPIRED',
          message:
              'The verification code has expired. Please request a new code.',
        );
      } else {
        return CloudVerificationResult(
          success: false,
          error: e.code,
          message: e.message ?? 'Verification failed.',
        );
      }
    } catch (e) {
      debugPrint('verifyAutomatedPhoneOtp unexpected error: $e');
      return CloudVerificationResult(
        success: false,
        error: 'SERVER_ERROR',
        message: e.toString(),
      );
    }
  }

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

  /// Requests a cryptographically generated & hashed OTP session from Firestore.
  static Future<OtpSession> requestCloudOtp({
    required String customerName,
    required String phoneNumber,
    required double amount,
  }) async {
    final user = Firebase.apps.isNotEmpty ? FirebaseAuth.instance.currentUser : null;
    if (user != null) {
      try {
        final String cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
        final String otp = generateOtp();
        final String verificationId = const Uuid().v4();
        final String verificationToken = const Uuid().v4();
        final DateTime now = DateTime.now();
        final DateTime expiresAt = now.add(otpValidityDuration);

        // Salt and hash the OTP with customer number and lender user_id
        final String otpHash = sha256
            .convert(utf8.encode('$otp$cleanNumber${user.uid}'))
            .toString();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('loan_verifications')
            .doc(verificationId)
            .set({
          'id': verificationId,
          'owner_id': user.uid,
          'customer_number': cleanNumber,
          'customer_name': customerName,
          'loan_amount': amount,
          'otp_hash': otpHash,
          'status': 'PENDING',
          'attempts': 0,
          'verification_token': verificationToken,
          'expires_at': Timestamp.fromDate(expiresAt),
          'created_at': Timestamp.fromDate(now),
          'updated_at': Timestamp.fromDate(now),
        });

        return OtpSession(
          verificationId: verificationId,
          code: otp,
          createdAt: now,
          expiresAt: expiresAt,
          phoneNumber: phoneNumber,
          customerName: customerName,
          amount: amount,
          isCloudVerified: true,
        );
      } catch (e) {
        debugPrint('Firestore request_loan_otp error: $e');
        throw CloudOtpException(
          'Failed to generate secure OTP from server: $e',
        );
      }
    }

    // In debug/test mode when user is not logged in or Firebase is not initialized
    if (kDebugMode) {
      return createSession(
        customerName: customerName,
        phoneNumber: phoneNumber,
        amount: amount,
      );
    }

    throw const CloudOtpException(
      'Active internet connection and login required for customer OTP verification.',
    );
  }

  /// Verifies the entered OTP code against Firestore-stored hash.
  static Future<CloudVerificationResult> verifyCloudOtp({
    required OtpSession session,
    required String enteredPin,
  }) async {
    if (session.isAutomated && session.verificationId != null) {
      return verifyAutomatedPhoneOtp(
        verificationId: session.verificationId!,
        enteredPin: enteredPin,
        customerNumber: session.phoneNumber,
        customerName: session.customerName,
        loanAmount: session.amount,
      );
    }

    final user = Firebase.apps.isNotEmpty ? FirebaseAuth.instance.currentUser : null;
    if (session.isCloudVerified && session.verificationId != null && user != null) {
      try {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('loan_verifications')
            .doc(session.verificationId);

        final docSnap = await docRef.get();
        if (!docSnap.exists || docSnap.data() == null) {
          return const CloudVerificationResult(
            success: false,
            error: 'NOT_FOUND',
            message: 'Verification session not found.',
          );
        }

        final data = docSnap.data()!;
        final String status = data['status'] as String? ?? 'PENDING';
        final int attempts = data['attempts'] as int? ?? 0;
        final Timestamp? expiresTimestamp = data['expires_at'] as Timestamp?;
        final DateTime expiresAt =
            expiresTimestamp?.toDate() ?? session.expiresAt;
        final String verificationToken =
            data['verification_token'] as String? ?? const Uuid().v4();

        if (status == 'EXPIRED' || DateTime.now().isAfter(expiresAt)) {
          await docRef.update({
            'status': 'EXPIRED',
            'updated_at': Timestamp.now(),
          });
          return const CloudVerificationResult(
            success: false,
            error: 'EXPIRED',
            message: 'OTP has expired. Please request a new code.',
          );
        }

        if (status == 'VERIFIED' || status == 'CONSUMED') {
          return CloudVerificationResult(
            success: true,
            verificationToken: verificationToken,
            message: 'Already verified.',
          );
        }

        if (attempts >= 5) {
          await docRef.update({
            'status': 'EXPIRED',
            'updated_at': Timestamp.now(),
          });
          return const CloudVerificationResult(
            success: false,
            error: 'MAX_ATTEMPTS',
            message: 'Too many incorrect attempts. Please request a new code.',
          );
        }

        final String cleanNumber =
            session.phoneNumber.replaceAll(RegExp(r'\s+'), '');
        final String computedHash = sha256
            .convert(utf8.encode('${enteredPin.trim()}$cleanNumber${user.uid}'))
            .toString();

        final String storedHash = data['otp_hash'] as String? ?? '';

        if (computedHash == storedHash) {
          await docRef.update({
            'status': 'VERIFIED',
            'verified_at': Timestamp.now(),
            'updated_at': Timestamp.now(),
          });
          return CloudVerificationResult(
            success: true,
            verificationToken: verificationToken,
            message: 'Verified successfully.',
          );
        } else {
          final int newAttempts = attempts + 1;
          await docRef.update({
            'attempts': newAttempts,
            if (newAttempts >= 5) 'status': 'EXPIRED',
            'updated_at': Timestamp.now(),
          });

          return CloudVerificationResult(
            success: false,
            error: newAttempts >= 5 ? 'MAX_ATTEMPTS' : 'INVALID_OTP',
            remainingAttempts: (5 - newAttempts).clamp(0, 5),
            message: newAttempts >= 5
                ? 'Too many incorrect attempts. Please request a new code.'
                : 'Invalid OTP code',
          );
        }
      } catch (e) {
        debugPrint('Firestore verify_loan_otp error: $e');
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
    return sendManualSms(phoneNumber: phoneNumber, message: message);
  }

  /// Explicit manual fallback launching the device SMS messenger.
  static Future<bool> sendManualSms({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      return await Utility.sendSms(
        phoneNumber: phoneNumber,
        body: message,
      );
    } catch (e) {
      debugPrint('OtpService.sendManualSms failed: $e');
      return false;
    }
  }
}
