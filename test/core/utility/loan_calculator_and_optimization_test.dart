import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/core/logic/logic.dart';
import 'package:self_finance/core/utility/user_utility.dart';

void main() {
  group('LoanCalculator Optimization Tests', () {
    test('LoanCalculator precomputes months and remainingDays accurately', () {
      final start = DateTime(2025, 1, 10);
      final end = DateTime(2025, 4, 15);

      final calc = LoanCalculator(
        takenAmount: 10000.0,
        rateOfInterest: 2.0, // 2% per month
        takenDate: start,
        tenureDate: end,
      );

      // 3 full calendar months (Jan 10 - Apr 10) + 5 remaining days (Apr 10 - Apr 15)
      expect(calc.months, equals(3));
      expect(calc.remainingDays, equals(5));
      expect(calc.monthsAndRemainingDays, equals('3 Months - 5 Days'));

      // Monthly interest: 10,000 * 0.02 = 200
      expect(calc.interestPerMonth, equals(200.0));
      // Daily interest: 200 / 30 = 6.6666...
      // 3 months * 200 = 600
      // 5 days * (200 / 30) = 33.3333...
      // Total interest: 633.3333...
      expect(calc.totalInterestAmount, closeTo(633.33, 0.01));
      expect(calc.totalAmount, closeTo(10633.33, 0.01));
    });

    test('LoanCalculator handles zero duration gracefully', () {
      final date = DateTime(2025, 5);
      final calc = LoanCalculator(
        takenAmount: 5000.0,
        rateOfInterest: 3.0,
        takenDate: date,
        tenureDate: date,
      );

      expect(calc.months, equals(0));
      expect(calc.remainingDays, equals(0));
      expect(calc.totalInterestAmount, equals(0.0));
      expect(calc.totalAmount, equals(5000.0));
    });

    test('Utility.isValidPhoneNumber validates standard mobile numbers', () {
      expect(Utility.isValidPhoneNumber('9876543210'), isTrue);
      expect(Utility.isValidPhoneNumber('+919876543210'), isTrue);
      expect(Utility.isValidPhoneNumber(''), isFalse);
      expect(Utility.isValidPhoneNumber('123'), isFalse);
    });

    test('Utility.compactNumber formats large amounts properly', () {
      expect(Utility.compactNumber(500), equals('500'));
      expect(Utility.compactNumber(1500), equals('1.5K'));
      expect(Utility.compactNumber(250000), equals('2.5L'));
      expect(Utility.compactNumber(10000000), equals('1.0Cr'));
    });
  });
}
