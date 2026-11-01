import 'package:flutter/foundation.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/customer/models/customer_portal_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  /// Requests a 4-digit OTP for the registered customer phone number.
  static Future<CustomerPortalAuthResponse> requestOtp(String phoneNumber) async {
    if (!Utility.isSupabaseInitialized) {
      return CustomerPortalAuthResponse(
        success: false,
        error: 'OFFLINE',
        message: 'Active internet connection required to access customer portal.',
      );
    }

    try {
      final dynamic response = await Supabase.instance.client.rpc(
        'customer_portal_request_otp',
        params: {
          'p_phone_number': phoneNumber.trim(),
        },
      );

      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        return CustomerPortalAuthResponse(
          success: map['success'] == true,
          sessionId: map['session_id'] as String?,
          customerName: map['customer_name'] as String?,
          otpCode: map['otp_code'] as String?,
          error: map['error'] as String?,
          message: map['message'] as String?,
        );
      }
      return CustomerPortalAuthResponse(
        success: false,
        error: 'INVALID_RESPONSE',
        message: 'Unexpected server response.',
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
    if (!Utility.isSupabaseInitialized) {
      return CustomerPortalAuthResponse(
        success: false,
        error: 'OFFLINE',
        message: 'Active internet connection required.',
      );
    }

    try {
      final dynamic response = await Supabase.instance.client.rpc(
        'customer_portal_verify_otp',
        params: {
          'p_session_id': sessionId,
          'p_entered_otp': enteredOtp.trim(),
        },
      );

      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        final bool success = map['success'] == true;
        final String? portalToken = map['portal_token'] as String?;
        final String? phoneNumber = map['phone_number'] as String?;

        if (success && portalToken != null && phoneNumber != null) {
          await saveSession(portalToken: portalToken, phoneNumber: phoneNumber);
        }

        return CustomerPortalAuthResponse(
          success: success,
          portalToken: portalToken,
          phoneNumber: phoneNumber,
          error: map['error'] as String?,
          message: map['message'] as String?,
          remainingAttempts: map['remaining_attempts'] as int?,
        );
      }
      return CustomerPortalAuthResponse(
        success: false,
        error: 'INVALID_RESPONSE',
        message: 'Unexpected server response.',
      );
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
    if (!Utility.isSupabaseInitialized) {
      throw StateError('Internet connection required.');
    }

    try {
      final dynamic response = await Supabase.instance.client.rpc(
        'customer_portal_get_data',
        params: {
          'p_portal_token': portalToken,
        },
      );

      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        if (map['success'] == true) {
          return CustomerPortalData.fromJson(map);
        } else if (map['error'] == 'UNAUTHORIZED') {
          await clearSession();
          throw StateError(map['message']?.toString() ?? 'Session expired.');
        }
      }
      return null;
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
