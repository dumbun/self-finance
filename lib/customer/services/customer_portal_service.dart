import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:self_finance/core/utility/otp_service.dart';
import 'package:self_finance/customer/models/customer_portal_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class CustomerPortalAuthResponse {
  final bool success;
  final String? sessionId;
  final String? customerName;
  final String? otpCode;
  final String? portalToken;
  final String? phoneNumber;
  final String? error;
  final String? message;
  final int? remainingAttempts;

  CustomerPortalAuthResponse({
    required this.success,
    this.sessionId,
    this.customerName,
    this.otpCode,
    this.portalToken,
    this.phoneNumber,
    this.error,
    this.message,
    this.remainingAttempts,
  });
}

class CustomerPortalService {
  static const String _prefPortalTokenKey = 'customer_portal_token';
  static const String _prefCustomerPhoneKey = 'customer_portal_phone';

  /// Checks if a customer record matching [phoneNumber] exists in Firestore
  /// under any common phone format variation. Returns the document data or null.
  static Future<Map<String, dynamic>?> checkCustomerExists(
      String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleanPhone.isEmpty || Firebase.apps.isEmpty) return null;

    final firestore = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> query = await firestore
        .collectionGroup('customers')
        .where('contact_number', isEqualTo: phoneNumber.trim())
        .limit(1)
        .get();

    if (query.docs.isEmpty && cleanPhone != phoneNumber.trim()) {
      query = await firestore
          .collectionGroup('customers')
          .where('contact_number', isEqualTo: cleanPhone)
          .limit(1)
          .get();
    }

    if (query.docs.isEmpty && cleanPhone.length >= 10) {
      final last10 = cleanPhone.substring(cleanPhone.length - 10);
      query = await firestore
          .collectionGroup('customers')
          .where('contact_number', isEqualTo: last10)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        query = await firestore
            .collectionGroup('customers')
            .where('contact_number', isEqualTo: '+91$last10')
            .limit(1)
            .get();
      }

      if (query.docs.isEmpty) {
        query = await firestore
            .collectionGroup('customers')
            .where('contact_number', isEqualTo: '+91 $last10')
            .limit(1)
            .get();
      }
    }

    if (query.docs.isEmpty) return null;
    return query.docs.first.data();
  }

  /// Dispatches an automated SMS to the customer's phone via Firebase Phone Auth.
  static Future<void> requestPhoneAuthOtp({
    required String phoneNumber,
    required void Function(
            String verificationId, int? resendToken, String customerName)
        onCodeSent,
    required void Function(PhoneAuthCredential credential)
        onVerificationCompleted,
    required void Function(FirebaseAuthException error) onVerificationFailed,
    required void Function(String verificationId) onCodeAutoRetrievalTimeout,
    int? resendToken,
  }) async {
    final customer = await checkCustomerExists(phoneNumber);
    if (customer == null) {
      throw StateError(
        'No customer record found with this phone number. Please contact your lender.',
      );
    }
    final customerName = customer['name'] as String? ?? 'Customer';

    await OtpService.sendAutomatedPhoneOtp(
      phoneNumber: phoneNumber,
      resendToken: resendToken,
      onCodeSent: (String verificationId, int? token) {
        onCodeSent(verificationId, token, customerName);
      },
      onVerificationCompleted: onVerificationCompleted,
      onVerificationFailed: onVerificationFailed,
      onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    );
  }

  /// Verifies an entered 6-digit SMS code against Firebase Phone Auth and saves the session.
  static Future<CustomerPortalAuthResponse> verifyPhoneAuthOtp({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );

      final auth = await OtpService.getSecondaryAuth();
      final userCredential = await auth.signInWithCredential(credential);
      await auth.signOut();

      if (userCredential.user != null) {
        final portalToken = const Uuid().v4();
        final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
        final sessionId = const Uuid().v4();
        final expiresAt = DateTime.now().add(const Duration(days: 30));

        await FirebaseFirestore.instance
            .collection('customer_portal_sessions')
            .doc(sessionId)
            .set({
          'id': sessionId,
          'phone_number': cleanPhone,
          'status': 'VERIFIED',
          'portal_token': portalToken,
          'verified_at': Timestamp.now(),
          'token_expires_at': Timestamp.fromDate(expiresAt),
          'created_at': Timestamp.now(),
        });

        await saveSession(portalToken: portalToken, phoneNumber: cleanPhone);

        return CustomerPortalAuthResponse(
          success: true,
          portalToken: portalToken,
          phoneNumber: cleanPhone,
          sessionId: sessionId,
        );
      } else {
        return CustomerPortalAuthResponse(
          success: false,
          error: 'INVALID_OTP',
          message: 'Invalid verification code.',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        return CustomerPortalAuthResponse(
          success: false,
          error: 'INVALID_OTP',
          message: 'Invalid verification code. Please check and try again.',
        );
      } else if (e.code == 'session-expired') {
        return CustomerPortalAuthResponse(
          success: false,
          error: 'EXPIRED',
          message: 'Verification code expired. Please request a new code.',
        );
      } else {
        return CustomerPortalAuthResponse(
          success: false,
          error: e.code,
          message: e.message ?? 'Verification failed.',
        );
      }
    } catch (e) {
      return CustomerPortalAuthResponse(
        success: false,
        error: 'SERVER_ERROR',
        message: e.toString(),
      );
    }
  }

  /// Requests a 4-digit OTP for the registered customer phone number (Firestore fallback).
  static Future<CustomerPortalAuthResponse> requestOtp(String phoneNumber) async {
    if (Firebase.apps.isEmpty) {
      return CustomerPortalAuthResponse(
        success: false,
        error: 'OFFLINE',
        message: 'Active internet connection required to access customer portal.',
      );
    }

    try {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
      if (cleanPhone.isEmpty) {
        return CustomerPortalAuthResponse(
          success: false,
          error: 'INVALID_PHONE',
          message: 'Please enter a valid phone number.',
        );
      }

      final customerDoc = await checkCustomerExists(phoneNumber);
      if (customerDoc == null) {
        return CustomerPortalAuthResponse(
          success: false,
          error: 'CUSTOMER_NOT_FOUND',
          message: 'No customer record found with this phone number. Please contact your lender.',
        );
      }

      final customerName = customerDoc['name'] as String? ?? 'Customer';

      final otpCode = OtpService.generateOtp();
      final sessionId = const Uuid().v4();
      final otpHash =
          sha256.convert(utf8.encode('$otpCode$cleanPhone')).toString();
      final expiresAt = DateTime.now().add(const Duration(minutes: 5));
      final firestore = FirebaseFirestore.instance;

      await firestore.collection('customer_portal_sessions').doc(sessionId).set({
        'id': sessionId,
        'phone_number': cleanPhone,
        'customer_name': customerName,
        'otp_hash': otpHash,
        'status': 'PENDING',
        'attempts': 0,
        'expires_at': Timestamp.fromDate(expiresAt),
        'created_at': Timestamp.now(),
      });

      return CustomerPortalAuthResponse(
        success: true,
        sessionId: sessionId,
        customerName: customerName,
        otpCode: otpCode,
      );
    } on FirebaseException catch (e) {
      debugPrint(
          'customer_portal_request_otp FirebaseException: ${e.code} - ${e.message}');
      if (e.code == 'failed-precondition' ||
          (e.message != null && e.message!.contains('not ready yet'))) {
        return CustomerPortalAuthResponse(
          success: false,
          error: 'INDEX_BUILDING',
          message:
              'Database search index is currently building on Firebase. Please wait 1-2 minutes and try again.',
        );
      }
      return CustomerPortalAuthResponse(
        success: false,
        error: e.code,
        message: e.message ?? 'An error occurred while connecting to server.',
      );
    } catch (e) {
      debugPrint('customer_portal_request_otp error: $e');
      return CustomerPortalAuthResponse(
        success: false,
        error: 'SERVER_ERROR',
        message: e.toString(),
      );
    }
  }

  /// Verifies the 4-digit OTP code against the session.
  static Future<CustomerPortalAuthResponse> verifyOtp({
    required String sessionId,
    required String enteredOtp,
  }) async {
    if (Firebase.apps.isEmpty) {
      return CustomerPortalAuthResponse(
        success: false,
        error: 'OFFLINE',
        message: 'Active internet connection required.',
      );
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final docRef =
          firestore.collection('customer_portal_sessions').doc(sessionId);
      final docSnap = await docRef.get();

      if (!docSnap.exists || docSnap.data() == null) {
        return CustomerPortalAuthResponse(
          success: false,
          error: 'SESSION_NOT_FOUND',
          message: 'Verification session expired or not found.',
        );
      }

      final data = docSnap.data()!;
      final status = data['status'] as String? ?? 'PENDING';
      final attempts = data['attempts'] as int? ?? 0;
      final expiresAt =
          (data['expires_at'] as Timestamp?)?.toDate() ?? DateTime.now();
      final phone = data['phone_number'] as String? ?? '';

      if (status == 'EXPIRED' || DateTime.now().isAfter(expiresAt)) {
        await docRef.update({'status': 'EXPIRED', 'updated_at': Timestamp.now()});
        return CustomerPortalAuthResponse(
          success: false,
          error: 'EXPIRED',
          message: 'OTP has expired. Please request a new code.',
        );
      }

      if (attempts >= 5) {
        await docRef.update({'status': 'EXPIRED', 'updated_at': Timestamp.now()});
        return CustomerPortalAuthResponse(
          success: false,
          error: 'MAX_ATTEMPTS',
          message: 'Too many incorrect attempts. Please request a new code.',
        );
      }

      final computedHash =
          sha256.convert(utf8.encode('${enteredOtp.trim()}$phone')).toString();
      final storedHash = data['otp_hash'] as String? ?? '';

      if (computedHash == storedHash) {
        final portalToken = const Uuid().v4();
        final tokenExpiry = DateTime.now().add(const Duration(days: 30));

        await docRef.update({
          'status': 'VERIFIED',
          'portal_token': portalToken,
          'token_expires_at': Timestamp.fromDate(tokenExpiry),
          'updated_at': Timestamp.now(),
        });

        await saveSession(portalToken: portalToken, phoneNumber: phone);

        return CustomerPortalAuthResponse(
          success: true,
          portalToken: portalToken,
          phoneNumber: phone,
        );
      } else {
        final newAttempts = attempts + 1;
        await docRef.update({
          'attempts': newAttempts,
          if (newAttempts >= 5) 'status': 'EXPIRED',
          'updated_at': Timestamp.now(),
        });

        return CustomerPortalAuthResponse(
          success: false,
          error: newAttempts >= 5 ? 'MAX_ATTEMPTS' : 'INVALID_OTP',
          remainingAttempts: (5 - newAttempts).clamp(0, 5),
          message: newAttempts >= 5
              ? 'Too many incorrect attempts. Please request a new code.'
              : 'Invalid OTP code. Please try again.',
        );
      }
    } catch (e) {
      debugPrint('customer_portal_verify_otp error: $e');
      return CustomerPortalAuthResponse(
        success: false,
        error: 'SERVER_ERROR',
        message: e.toString(),
      );
    }
  }

  /// Fetches the customer's portal dashboard data.
  static Future<CustomerPortalData?> fetchPortalData(String portalToken) async {
    if (Firebase.apps.isEmpty) {
      throw StateError('Internet connection required.');
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final sessionQuery = await firestore
          .collection('customer_portal_sessions')
          .where('portal_token', isEqualTo: portalToken)
          .limit(1)
          .get();

      if (sessionQuery.docs.isEmpty) {
        throw StateError('Session expired or invalid. Please sign in again.');
      }

      final sessionDoc = sessionQuery.docs.first.data();
      if (sessionDoc['status'] != 'VERIFIED') {
        throw StateError('Session not verified. Please sign in again.');
      }

      final tokenExpiry =
          (sessionDoc['token_expires_at'] as Timestamp?)?.toDate();
      if (tokenExpiry != null && DateTime.now().isAfter(tokenExpiry)) {
        await clearSession();
        throw StateError('Session expired. Please sign in again.');
      }

      final phone = sessionDoc['phone_number'] as String? ?? '';

      // 1. Fetch customer profile under various formatting variations
      QuerySnapshot<Map<String, dynamic>> custQuery = await firestore
          .collectionGroup('customers')
          .where('contact_number', isEqualTo: phone.trim())
          .get();

      final cleanCustPhone = phone.replaceAll(RegExp(r'\s+'), '');
      if (custQuery.docs.isEmpty && cleanCustPhone != phone.trim()) {
        custQuery = await firestore
            .collectionGroup('customers')
            .where('contact_number', isEqualTo: cleanCustPhone)
            .get();
      }

      if (custQuery.docs.isEmpty && cleanCustPhone.length >= 10) {
        final last10 = cleanCustPhone.substring(cleanCustPhone.length - 10);
        custQuery = await firestore
            .collectionGroup('customers')
            .where('contact_number', isEqualTo: last10)
            .get();

        if (custQuery.docs.isEmpty) {
          custQuery = await firestore
              .collectionGroup('customers')
              .where('contact_number', isEqualTo: '+91$last10')
              .get();
        }

        if (custQuery.docs.isEmpty) {
          custQuery = await firestore
              .collectionGroup('customers')
              .where('contact_number', isEqualTo: '+91 $last10')
              .get();
        }
      }

      if (custQuery.docs.isEmpty) {
        return null;
      }

      final customerDoc = custQuery.docs.first;
      final customerData = customerDoc.data();
      final customerSyncId = customerDoc.id;

      // 2. Fetch loans (transactions)
      final txnsQuery = await firestore
          .collectionGroup('transactions')
          .where('customer_sync_id', isEqualTo: customerSyncId)
          .get();

      final List<Map<String, dynamic>> loansList = [];
      double totalBorrowed = 0.0;
      double totalRemaining = 0.0;
      double totalPaid = 0.0;
      final List<Map<String, dynamic>> paymentsList = [];

      for (final txnDoc in txnsQuery.docs) {
        final t = txnDoc.data();
        if (t['deleted_at'] != null) continue;

        final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
        final remaining = (t['remaining_amount'] as num?)?.toDouble() ?? 0.0;
        totalBorrowed += amount;
        totalRemaining += remaining;

        // Fetch item details if present
        Map<String, dynamic>? itemData;
        final itemSyncId = t['item_sync_id'] as String?;
        if (itemSyncId != null && itemSyncId.isNotEmpty) {
          final itemDocs = await firestore
              .collectionGroup('items')
              .where('id', isEqualTo: itemSyncId)
              .limit(1)
              .get();
          if (itemDocs.docs.isNotEmpty) {
            itemData = itemDocs.docs.first.data();
          }
        }

        loansList.add({
          'transaction_id': t['id'] ?? txnDoc.id,
          'amount': amount,
          'interest_rate': (t['interest_rate'] as num?)?.toDouble() ?? 0.0,
          'interest_amount': (t['interest_amount'] as num?)?.toDouble() ?? 0.0,
          'remaining_amount': remaining,
          'transaction_date': t['transaction_date'],
          'transaction_type': t['transaction_type'] ?? 'Active',
          'signature_path': t['signature_path'] ?? '',
          'created_at': t['created_at'],
          'item_id': itemSyncId,
          'item_name': itemData?['name'] ?? 'Collateral Item',
          'item_description': itemData?['description'] ?? '',
          'pawn_amount': (itemData?['pawn_amount'] as num?)?.toDouble() ?? 0.0,
          'item_status': itemData?['status'] ?? 'Active',
          'pawned_date': itemData?['pawned_date'],
          'expiry_date': itemData?['expiry_date'],
          'item_photo_path': itemData?['photo_path'] ?? '',
        });

        // 3. Fetch payments for this transaction
        final txnId = t['id'] ?? txnDoc.id;
        final paymentsQuery = await firestore
            .collectionGroup('payments')
            .where('transaction_sync_id', isEqualTo: txnId)
            .get();

        for (final pDoc in paymentsQuery.docs) {
          final p = pDoc.data();
          if (p['deleted_at'] != null) continue;
          final amtPaid = (p['amount_paid'] as num?)?.toDouble() ?? 0.0;
          totalPaid += amtPaid;
          paymentsList.add({
            'payment_id': p['id'] ?? pDoc.id,
            'transaction_id': txnId,
            'amount_paid': amtPaid,
            'payment_type': p['payment_type'] ?? 'Cash',
            'payment_date': p['payment_date'],
            'created_at': p['created_at'],
          });
        }
      }

      final payload = {
        'customer': {
          'name': customerData['name'] ?? 'Customer',
          'guardian_name': customerData['guardian_name'] ?? '',
          'contact_number': customerData['contact_number'] ?? phone,
          'address': customerData['address'] ?? '',
          'photo_path': customerData['photo_path'] ?? '',
          'proof_path': customerData['proof_path'] ?? '',
          'created_at': customerData['created_at'],
        },
        'summary': {
          'total_loans': loansList.length,
          'total_borrowed': totalBorrowed,
          'total_remaining': totalRemaining,
          'total_paid': totalPaid,
        },
        'loans': loansList,
        'payments': paymentsList,
      };

      return CustomerPortalData.fromJson(payload);
    } catch (e) {
      debugPrint('customer_portal_get_data error: $e');
      rethrow;
    }
  }

  /// Saves the customer's portal session in local preferences.
  static Future<void> saveSession({
    required String portalToken,
    required String phoneNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefPortalTokenKey, portalToken);
    await prefs.setString(_prefCustomerPhoneKey, phoneNumber);
  }

  /// Returns the saved portal token if active, or `null`.
  static Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefPortalTokenKey);
  }

  /// Returns the saved customer phone number, or `null`.
  static Future<String?> getSavedPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefCustomerPhoneKey);
  }

  /// Clears the customer's portal session on sign-out.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefPortalTokenKey);
    await prefs.remove(_prefCustomerPhoneKey);
  }
}
