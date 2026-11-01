import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/core/utility/otp_service.dart';
import 'package:self_finance/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

void main() {
  group('OtpService & OtpSession Tests', () {
    test('generateOtp generates a 4-digit numeric string by default', () {
      for (int i = 0; i < 50; i++) {
        final String otp = OtpService.generateOtp();
        expect(otp.length, equals(4));
        expect(int.tryParse(otp), isNotNull);
        expect(int.parse(otp), greaterThanOrEqualTo(1000));
        expect(int.parse(otp), lessThanOrEqualTo(9999));
      }
    });

    test('generateOtp supports custom digit counts', () {
      final String otp6 = OtpService.generateOtp(digits: 6);
      expect(otp6.length, equals(6));
      expect(int.tryParse(otp6), isNotNull);
      expect(int.parse(otp6), greaterThanOrEqualTo(100000));
      expect(int.parse(otp6), lessThanOrEqualTo(999999));
    });

    test('createSession populates session fields correctly', () {
      final OtpSession session = OtpService.createSession(
        customerName: 'Rahul Kumar',
        phoneNumber: '+91 9876543210',
        amount: 25000.0,
      );

      expect(session.customerName, equals('Rahul Kumar'));
      expect(session.phoneNumber, equals('+91 9876543210'));
      expect(session.amount, equals(25000.0));
      expect(session.code.length, equals(4));
      expect(session.isExpired, isFalse);
      expect(
        session.expiresAt.difference(session.createdAt).inMinutes,
        equals(5),
      );
    });

    test('verify returns true for matching code and false for incorrect code', () {
      final OtpSession session = OtpSession(
        code: '4567',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        phoneNumber: '+919876543210',
        customerName: 'Alice',
        amount: 10000.0,
      );

      expect(session.verify('4567'), isTrue);
      expect(session.verify(' 4567 '), isTrue);
      expect(session.verify('1234'), isFalse);
      expect(session.verify(''), isFalse);
    });

    test('verify rejects code when session is expired', () {
      final OtpSession expiredSession = OtpSession(
        code: '1234',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        phoneNumber: '+919876543210',
        customerName: 'Bob',
        amount: 5000.0,
      );

      expect(expiredSession.isExpired, isTrue);
      expect(expiredSession.verify('1234'), isFalse);
    });

    test('formatToE164 normalizes numbers correctly with and without country code', () {
      expect(OtpService.formatToE164('9876543210'), equals('+919876543210'));
      expect(OtpService.formatToE164('+91 98765 43210'), equals('+919876543210'));
      expect(OtpService.formatToE164('+1 (555) 234-5678'), equals('+15552345678'));
      expect(OtpService.formatToE164('09876543210'), equals('+919876543210'));
      expect(OtpService.formatToE164('00919876543210'), equals('+919876543210'));
    });

    test('OtpSession supports automated phone verification parameters', () {
      final OtpSession session = OtpSession(
        verificationId: 'v-12345',
        code: '',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        phoneNumber: '+919876543210',
        customerName: 'Suresh',
        amount: 50000.0,
        isCloudVerified: true,
        isAutomated: true,
        codeLength: 6,
        resendToken: 9988,
      );

      expect(session.isAutomated, isTrue);
      expect(session.codeLength, equals(6));
      expect(session.verificationId, equals('v-12345'));
      expect(session.resendToken, equals(9988));
      expect(session.isExpired, isFalse);
    });
  });

  group('OTP Localization Tests', () {
    test('English localizations contain all OTP keys', () {
      final AppLocalizations en = lookupAppLocalizations(const Locale('en'));
      expect(en.customerOtpVerification, equals('Customer OTP Verification'));
      expect(en.verifyAndConfirm, equals('Verify & Confirm'));
      expect(en.resendOtp, equals('Resend OTP'));
      expect(en.invalidOtpCode, contains('Invalid OTP code'));
      expect(en.otpExpired, contains('expired'));
      expect(en.openSmsApp, equals('Open SMS App'));
      expect(en.resendOtpIn(45), equals('Resend OTP in 45s'));
      expect(
        en.otpSmsTemplate('10,000', '1234'),
        contains('1234'),
      );
    });

    test('Hindi localizations contain all OTP keys', () {
      final AppLocalizations hi = lookupAppLocalizations(const Locale('hi'));
      expect(hi.customerOtpVerification, equals('ग्राहक ओटीपी सत्यापन'));
      expect(hi.verifyAndConfirm, equals('सत्यापित करें और पुष्टि करें'));
      expect(hi.resendOtp, equals('ओटीपी पुनः भेजें'));
      expect(hi.resendOtpIn(30), equals('30s में ओटीपी पुनः भेजें'));
      expect(
        hi.otpSmsTemplate('10,000', '1234'),
        contains('1234'),
      );
    });

    test('Telugu localizations contain all OTP keys', () {
      final AppLocalizations te = lookupAppLocalizations(const Locale('te'));
      expect(te.customerOtpVerification, equals('కస్టమర్ ఓటీపీ ధృవీకరణ'));
      expect(te.verifyAndConfirm, equals('ధృవీకరించి నిర్ధారించండి'));
      expect(te.resendOtp, equals('ఓటీపీని మళ్లీ పంపండి'));
      expect(te.resendOtpIn(20), equals('20s లో ఓటీపీని మళ్లీ పంపండి'));
      expect(
        te.otpSmsTemplate('10,000', '1234'),
        contains('1234'),
      );
    });
  });
}
