import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/core/logic/logic.dart';

void main() {
  // ---------------------------------------------------------------------------
  // LoanCalculator — Simple Interest
  // ---------------------------------------------------------------------------
  group('LoanCalculator · Simple Interest', () {
    // ── Same-day edge cases ──────────────────────────────────────────────────

    test('same day · inclusiveDays:true  → days = 1', () {
      final calc = LoanCalculator(
        takenAmount: 1000,
        rateOfInterest: 3,
        takenDate: DateTime(2026, 3, 1),
        tenureDate: DateTime(2026, 3, 1),
        inclusiveDays: true,
      );

      debugPrint('--- same day (inclusiveDays:true) ---');
      debugPrint('days              : ${calc.days}');

      expect(calc.days, 1);
    });

    test('same day · inclusiveDays:false → zero interest', () {
      final LoanCalculator calc = LoanCalculator(
        takenAmount: 1000,
        rateOfInterest: 3,
        takenDate: DateTime(2026, 3, 1),
        tenureDate: DateTime(2026, 3, 1),
      );

      debugPrint('--- same day (inclusiveDays:false) ---');
      debugPrint('monthsAndDays     : ${calc.monthsAndRemainingDays}');
      debugPrint('totalInterest     : ${calc.totalInterestAmount}');
      debugPrint('totalAmount       : ${calc.totalAmount}');

      expect(calc.monthsAndRemainingDays, '0 Months - 0 Days');
      expect(calc.totalInterestAmount, 0);
      expect(calc.totalAmount, 1000);
    });

    // ── Day-level precision ──────────────────────────────────────────────────

    test('1 day apart → 1 day of interest', () {
      final calc = LoanCalculator(
        takenAmount: 1000,
        rateOfInterest: 3,
        takenDate: DateTime(2026, 3, 1),
        tenureDate: DateTime(2026, 3, 2),
      );

      // monthly interest = 1000 × 3% = 30  →  daily = 30 / 30 = 1.00
      debugPrint('--- 1 day apart ---');
      debugPrint('interestPerDay    : ${calc.interestPerDay}');
      debugPrint('monthsAndDays     : ${calc.monthsAndRemainingDays}');
      debugPrint('totalInterest     : ${calc.totalInterestAmount}');
      debugPrint('totalAmount       : ${calc.totalAmount}');

      expect(calc.interestPerDay, closeTo(1.0, 1e-9));
      expect(calc.monthsAndRemainingDays, '0 Months - 1 Days');
      expect(calc.totalInterestAmount, closeTo(1.0, 1e-9));
      expect(calc.totalAmount, closeTo(1001.0, 1e-9));
    });

    test('15 days apart → 15 × dailyRate interest', () {
      final calc = LoanCalculator(
        takenAmount: 1000,
        rateOfInterest: 3,
        takenDate: DateTime(2026, 3, 1),
        tenureDate: DateTime(2026, 3, 16),
      );

      // dailyRate = 3% / 30 = 0.1%  →  15 days = 15.00
      const expected = 1000 * 0.03 / 30 * 15;

      debugPrint('--- 15 days apart ---');
      debugPrint('monthsAndDays     : ${calc.monthsAndRemainingDays}');
      debugPrint('totalInterest     : ${calc.totalInterestAmount}');
      debugPrint('totalAmount       : ${calc.totalAmount}');

      expect(calc.monthsAndRemainingDays, '0 Months - 15 Days');
      expect(calc.totalInterestAmount, closeTo(expected, 1e-9));
      expect(calc.totalAmount, closeTo(1000 + expected, 1e-9));
    });

    // ── Exact calendar months ────────────────────────────────────────────────

    test('exact 1 calendar month → 30 interest', () {
      final calc = LoanCalculator(
        takenAmount: 1000,
        rateOfInterest: 3,
        takenDate: DateTime(2026, 1, 15),
        tenureDate: DateTime(2026, 2, 15),
      );

      debugPrint('--- exact 1 month ---');
      debugPrint('monthsAndDays     : ${calc.monthsAndRemainingDays}');
      debugPrint('interestPerMonth  : ${calc.interestPerMonth}');
      debugPrint('totalInterest     : ${calc.totalInterestAmount}');
      debugPrint('totalAmount       : ${calc.totalAmount}');

      expect(calc.monthsAndRemainingDays, '1 Months - 0 Days');
      expect(calc.totalInterestAmount, closeTo(30.0, 1e-9));
      expect(calc.totalAmount, closeTo(1030.0, 1e-9));
    });

    test('exact 3 calendar months → 90 interest', () {
      final calc = LoanCalculator(
        takenAmount: 1000,
        rateOfInterest: 3,
        takenDate: DateTime(2026, 1, 1),
        tenureDate: DateTime(2026, 4, 1),
      );

      // 3 months × 30 = 90
      debugPrint('--- exact 3 months ---');
      debugPrint('monthsAndDays     : ${calc.monthsAndRemainingDays}');
      debugPrint('totalInterest     : ${calc.totalInterestAmount}');
      debugPrint('totalAmount       : ${calc.totalAmount}');

      expect(calc.monthsAndRemainingDays, '3 Months - 0 Days');
      expect(calc.totalInterestAmount, closeTo(90.0, 1e-9));
      expect(calc.totalAmount, closeTo(1090.0, 1e-9));
    });

    test('exact 12 calendar months (1 year) → 360 interest', () {
      final calc = LoanCalculator(
        takenAmount: 1000,
        rateOfInterest: 3,
        takenDate: DateTime(2025, 3, 1),
        tenureDate: DateTime(2026, 3, 1),
      );

      // 12 months × 30 = 360
      debugPrint('--- exact 12 months ---');
      debugPrint('monthsAndDays     : ${calc.monthsAndRemainingDays}');
      debugPrint('totalInterest     : ${calc.totalInterestAmount}');
      debugPrint('totalAmount       : ${calc.totalAmount}');

      expect(calc.monthsAndRemainingDays, '12 Months - 0 Days');
      expect(calc.totalInterestAmount, closeTo(360.0, 1e-9));
      expect(calc.totalAmount, closeTo(1360.0, 1e-9));
    });

    // ── Mixed months + days ──────────────────────────────────────────────────

    test('1 month + 10 days → 40 interest', () {
      final calc = LoanCalculator(
        takenAmount: 1000,
        rateOfInterest: 3,
        takenDate: DateTime(2026, 1, 15),
        tenureDate: DateTime(2026, 2, 25),
      );

      // 1 month = 30, 10 days = 10  →  total = 40
      debugPrint('--- 1 month + 10 days ---');
      debugPrint('monthsAndDays     : ${calc.monthsAndRemainingDays}');
      debugPrint('totalInterest     : ${calc.totalInterestAmount}');
      debugPrint('totalAmount       : ${calc.totalAmount}');

      expect(calc.monthsAndRemainingDays, '1 Months - 10 Days');
      expect(calc.totalInterestAmount, closeTo(40.0, 1e-9));
      expect(calc.totalAmount, closeTo(1040.0, 1e-9));
    });

    test('2 months + 5 days → 65 interest', () {
      final calc = LoanCalculator(
        takenAmount: 1000,
        rateOfInterest: 3,
        takenDate: DateTime(2026, 1, 1),
        tenureDate: DateTime(2026, 3, 6),
      );

      // 2 months = 60, 5 days = 5  →  total = 65
      debugPrint('--- 2 months + 5 days ---');
      debugPrint('monthsAndDays     : ${calc.monthsAndRemainingDays}');
      debugPrint('totalInterest     : ${calc.totalInterestAmount}');
      debugPrint('totalAmount       : ${calc.totalAmount}');

      expect(calc.monthsAndRemainingDays, '2 Months - 5 Days');
      expect(calc.totalInterestAmount, closeTo(65.0, 1e-9));
      expect(calc.totalAmount, closeTo(1065.0, 1e-9));
    });

    // ── Month-end / short-month clamping ─────────────────────────────────────

    test('Jan 31 → Feb 28 (non-leap) counts as 1 full month', () {
      final calc = LoanCalculator(
        takenAmount: 1000,
        rateOfInterest: 3,
        takenDate: DateTime(2026, 1, 31),
        tenureDate: DateTime(2026, 2, 28),
      );

      debugPrint('--- Jan 31 → Feb 28 clamping ---');
      debugPrint('monthsAndDays     : ${calc.monthsAndRemainingDays}');
      debugPrint('totalInterest     : ${calc.totalInterestAmount}');
      debugPrint('taken amount      : ${calc.takenAmount}');

      expect(calc.monthsAndRemainingDays, '1 Months - 0 Days');
      expect(calc.totalInterestAmount, closeTo(30.0, 1e-9));
      expect(calc.totalAmount, closeTo(1030.0, 1e-9));
    });

    test('Jan 31 → Feb 29 (leap year 2024) counts as 1 full month', () {
      final calc = LoanCalculator(
        takenAmount: 1000,
        rateOfInterest: 3,
        takenDate: DateTime(2024, 1, 31),
        tenureDate: DateTime(2024, 2, 29),
      );

      debugPrint('--- Jan 31 → Feb 29 leap year ---');
      debugPrint('monthsAndDays     : ${calc.monthsAndRemainingDays}');
      debugPrint('totalInterest     : ${calc.totalInterestAmount}');

      expect(calc.monthsAndRemainingDays, '1 Months - 0 Days');
      expect(calc.totalInterestAmount, closeTo(30.0, 1e-9));
      expect(calc.totalAmount, closeTo(1030.0, 1e-9));
    });

    test('Mar 31 → Apr 30 counts as 1 full month', () {
      final calc = LoanCalculator(
        takenAmount: 1000,
        rateOfInterest: 3,
        takenDate: DateTime(2026, 3, 31),
        tenureDate: DateTime(2026, 4, 30),
      );

      debugPrint('--- Mar 31 → Apr 30 clamping ---');
      debugPrint('monthsAndDays     : ${calc.monthsAndRemainingDays}');
      debugPrint('totalInterest     : ${calc.totalInterestAmount}');

      expect(calc.monthsAndRemainingDays, '1 Months - 0 Days');
      expect(calc.totalInterestAmount, closeTo(30.0, 1e-9));
    });

    // ── Zero / fractional rate ───────────────────────────────────────────────

    test('zero interest rate → zero interest regardless of duration', () {
      final calc = LoanCalculator(
        takenAmount: 5000,
        rateOfInterest: 0,
        takenDate: DateTime(2026, 1, 1),
        tenureDate: DateTime(2026, 6, 1),
      );

      debugPrint('--- zero rate ---');
      debugPrint('totalInterest     : ${calc.totalInterestAmount}');
      debugPrint('totalAmount       : ${calc.totalAmount}');

      expect(calc.totalInterestAmount, 0.0);
      expect(calc.totalAmount, 5000.0);
    });

    test('fractional rate (1.5%) over 2 months', () {
      final calc = LoanCalculator(
        takenAmount: 1000,
        rateOfInterest: 1.5,
        takenDate: DateTime(2026, 1, 1),
        tenureDate: DateTime(2026, 3, 1),
      );

      // 2 months × (1000 × 1.5%) = 2 × 15 = 30
      debugPrint('--- 1.5% rate, 2 months ---');
      debugPrint('interestPerMonth  : ${calc.interestPerMonth}');
      debugPrint('totalInterest     : ${calc.totalInterestAmount}');
      debugPrint('totalAmount       : ${calc.totalAmount}');

      expect(calc.interestPerMonth, closeTo(15.0, 1e-9));
      expect(calc.totalInterestAmount, closeTo(30.0, 1e-9));
      expect(calc.totalAmount, closeTo(1030.0, 1e-9));
    });

    // ── Large principal ──────────────────────────────────────────────────────

    test('large principal (100 000) over 6 months at 2%', () {
      final calc = LoanCalculator(
        takenAmount: 100000,
        rateOfInterest: 2,
        takenDate: DateTime(2026, 1, 1),
        tenureDate: DateTime(2026, 7, 1),
      );

      // 6 months × (100 000 × 2%) = 6 × 2000 = 12 000
      debugPrint('--- large principal ---');
      debugPrint('interestPerMonth  : ${calc.interestPerMonth}');
      debugPrint('totalInterest     : ${calc.totalInterestAmount}');
      debugPrint('totalAmount       : ${calc.totalAmount}');

      expect(calc.interestPerMonth, closeTo(2000.0, 1e-9));
      expect(calc.totalInterestAmount, closeTo(12000.0, 1e-9));
      expect(calc.totalAmount, closeTo(112000.0, 1e-9));
    });

    // ── Rounded helpers ──────────────────────────────────────────────────────

    test('rounded helpers match 2 decimal places', () {
      final calc = LoanCalculator(
        takenAmount: 1000,
        rateOfInterest: 3,
        takenDate: DateTime(2026, 1, 15),
        tenureDate: DateTime(2026, 2, 25),
      );

      debugPrint('--- rounded helpers ---');
      debugPrint('totalAmountRounded        : ${calc.totalAmountRounded}');
      debugPrint(
        'totalInterestAmountRounded: ${calc.totalInterestAmountRounded}',
      );

      expect(
        calc.totalAmountRounded,
        double.parse(calc.totalAmount.toStringAsFixed(2)),
      );
      expect(
        calc.totalInterestAmountRounded,
        double.parse(calc.totalInterestAmount.toStringAsFixed(2)),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // LoanCalculator — Compound Interest
  // ---------------------------------------------------------------------------
  group('LoanCalculator · Compound Interest', () {
    test('same day → compound interest = 0, total = principal', () {
      final calc = LoanCalculator(
        takenAmount: 1000,
        rateOfInterest: 3,
        takenDate: DateTime(2026, 3, 1),
        tenureDate: DateTime(2026, 3, 1),
      );

      debugPrint('--- compound · same day ---');
      debugPrint('compoundInterest  : ${calc.compoundInterestAmount}');
      debugPrint('compoundTotal     : ${calc.compoundTotalAmount}');

      expect(calc.compoundInterestAmount, closeTo(0.0, 1e-9));
      expect(calc.compoundTotalAmount, closeTo(1000.0, 1e-9));
    });

    test("my rtest ", () {
      final cal = LoanCalculator(
        takenAmount: 40000,
        rateOfInterest: 2,
        takenDate: DateTime(2026, 01, 30),
        tenureDate: DateTime(2026, 03, 03),
      );
      expect(cal.months, 1);
      expect(cal.remainingDays, 3);
    });

    test('1 full month compound total', () {
      final calc = LoanCalculator(
        takenAmount: 1000,
        rateOfInterest: 3,
        takenDate: DateTime(2026, 1, 15),
        tenureDate: DateTime(2026, 2, 15),
      );

      final expected = 1000 * pow(1 + 0.03, 1).toDouble();

      debugPrint('--- compound · 1 month ---');
      debugPrint('expected          : $expected');
      debugPrint('compoundTotal     : ${calc.compoundTotalAmount}');
      debugPrint('compoundInterest  : ${calc.compoundInterestAmount}');

      expect(calc.compoundTotalAmount, closeTo(expected, 1e-9));
      expect(calc.compoundInterestAmount, closeTo(expected - 1000, 1e-9));
    });

    test('3 full months compound total', () {
      final calc = LoanCalculator(
        takenAmount: 1000,
        rateOfInterest: 3,
        takenDate: DateTime(2026, 1, 1),
        tenureDate: DateTime(2026, 4, 1),
      );

      final expected = 1000 * pow(1 + 0.03, 3).toDouble();

      debugPrint('--- compound · 3 months ---');
      debugPrint('expected          : $expected');
      debugPrint('compoundTotal     : ${calc.compoundTotalAmount}');
      debugPrint('compoundInterest  : ${calc.compoundInterestAmount}');

      expect(calc.compoundTotalAmount, closeTo(expected, 1e-9));
      expect(calc.compoundInterestAmount, closeTo(expected - 1000, 1e-9));
    });

    test('1 month + 10 days compound total', () {
      final calc = LoanCalculator(
        takenAmount: 1000,
        rateOfInterest: 3,
        takenDate: DateTime(2026, 1, 15),
        tenureDate: DateTime(2026, 2, 25),
      );

      const monthlyRate = 0.03;
      const dailyRate = monthlyRate / 30.0;
      final expected =
          1000 *
          pow(1 + monthlyRate, 1).toDouble() *
          pow(1 + dailyRate, 10).toDouble();

      debugPrint('--- compound · 1 month + 10 days ---');
      debugPrint('expected          : $expected');
      debugPrint('compoundTotal     : ${calc.compoundTotalAmount}');
      debugPrint('compoundInterest  : ${calc.compoundInterestAmount}');

      expect(calc.compoundTotalAmount, closeTo(expected, 1e-9));
      expect(calc.compoundInterestAmount, closeTo(expected - 1000, 1e-9));
    });

    test('compound > simple for same period (money grows faster)', () {
      final calc = LoanCalculator(
        takenAmount: 1000,
        rateOfInterest: 3,
        takenDate: DateTime(2026, 1, 1),
        tenureDate: DateTime(2026, 7, 1),
      );

      debugPrint('--- compound vs simple · 6 months ---');
      debugPrint('simpleInterest    : ${calc.totalInterestAmount}');
      debugPrint('compoundInterest  : ${calc.compoundInterestAmount}');

      expect(
        calc.compoundInterestAmount,
        greaterThan(calc.totalInterestAmount),
      );
    });

    test('compound rounded helpers match 2 decimal places', () {
      final calc = LoanCalculator(
        takenAmount: 1000,
        rateOfInterest: 3,
        takenDate: DateTime(2026, 1, 1),
        tenureDate: DateTime(2026, 4, 1),
      );

      debugPrint('--- compound rounded helpers ---');
      debugPrint('compoundTotalRounded   : ${calc.compoundTotalAmountRounded}');
      debugPrint(
        'compoundInterestRounded: ${calc.compoundInterestAmountRounded}',
      );

      expect(
        calc.compoundTotalAmountRounded,
        double.parse(calc.compoundTotalAmount.toStringAsFixed(2)),
      );
      expect(
        calc.compoundInterestAmountRounded,
        double.parse(calc.compoundInterestAmount.toStringAsFixed(2)),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // DateUtils
  // ---------------------------------------------------------------------------
  group('DateUtils · dateOnly', () {
    test('strips time portion from datetime', () {
      final date = DateTime(2026, 3, 14, 22, 45, 10);
      final result = DateUtils.dateOnly(date);

      debugPrint('--- dateOnly ---');
      debugPrint('input             : $date');
      debugPrint('result            : $result');

      expect(result, DateTime(2026, 3, 14));
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
    });

    test('already midnight date is unchanged', () {
      final date = DateTime(2026, 6, 1);
      expect(DateUtils.dateOnly(date), date);
    });
  });

  group('DateUtils · parseDateOnly', () {
    test('parses dd-MM-yyyy correctly', () {
      final result = DateUtils.parseDateOnly('14-03-2026');

      debugPrint('--- parseDateOnly ---');
      debugPrint('parsed            : $result');

      expect(result, DateTime(2026, 3, 14));
    });

    test('parses year-boundary date correctly', () {
      final result = DateUtils.parseDateOnly('01-01-2026');
      expect(result, DateTime(2026, 1, 1));
    });

    test('parses last day of year correctly', () {
      final result = DateUtils.parseDateOnly('31-12-2025');
      expect(result, DateTime(2025, 12, 31));
    });
  });

  group('DateUtils · getDaysDifference', () {
    test('same day · inclusive = true → 1', () {
      final result = DateUtils.getDaysDifference(
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 3, 1),
        inclusive: true,
      );

      debugPrint('--- getDaysDifference same day inclusive ---');
      debugPrint('result            : $result');

      expect(result, 1);
    });

    test('1 day apart · inclusive = false → 1', () {
      final result = DateUtils.getDaysDifference(
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 3, 2),
        inclusive: false,
      );

      debugPrint('--- getDaysDifference 1 day non-inclusive ---');
      debugPrint('result            : $result');

      expect(result, 1);
    });

    test('1 day apart · inclusive = true → 2', () {
      final result = DateUtils.getDaysDifference(
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 3, 2),
        inclusive: true,
      );

      expect(result, 2);
    });

    test('30 days apart · inclusive = false → 30', () {
      final result = DateUtils.getDaysDifference(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 31),
        inclusive: false,
      );

      debugPrint('--- getDaysDifference 30 days ---');
      debugPrint('result            : $result');

      expect(result, 30);
    });

    test('end before start → 0', () {
      final result = DateUtils.getDaysDifference(
        startDate: DateTime(2026, 3, 2),
        endDate: DateTime(2026, 3, 1),
      );

      debugPrint('--- getDaysDifference end before start ---');
      debugPrint('result            : $result');

      expect(result, 0);
    });

    test('ignores time component in calculation', () {
      final result = DateUtils.getDaysDifference(
        startDate: DateTime(2026, 3, 1, 23, 59),
        endDate: DateTime(2026, 3, 2, 0, 1),
        inclusive: false,
      );

      expect(result, 1);
    });
  });

  group('DateUtils · getCalendarMonthsAndRemainingDays', () {
    test('same day → [0, 0]', () {
      final result = DateUtils.getCalendarMonthsAndRemainingDays(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 1),
      );

      debugPrint('--- calendar months · same day ---');
      debugPrint('result            : $result');

      expect(result, [0, 0]);
    });

    test('end before start → [0, 0]', () {
      final result = DateUtils.getCalendarMonthsAndRemainingDays(
        start: DateTime(2026, 3, 2),
        end: DateTime(2026, 3, 1),
      );

      expect(result, [0, 0]);
    });

    test('exact 1 month → [1, 0]', () {
      final result = DateUtils.getCalendarMonthsAndRemainingDays(
        start: DateTime(2026, 1, 15),
        end: DateTime(2026, 2, 15),
      );

      debugPrint('--- calendar months · exact 1 month ---');
      debugPrint('result            : $result');

      expect(result, [1, 0]);
    });

    test('1 month + 10 days → [1, 10]', () {
      final result = DateUtils.getCalendarMonthsAndRemainingDays(
        start: DateTime(2026, 1, 15),
        end: DateTime(2026, 2, 25),
      );

      expect(result, [1, 10]);
    });

    test('exact 3 months → [3, 0]', () {
      final result = DateUtils.getCalendarMonthsAndRemainingDays(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 4, 1),
      );

      debugPrint('--- calendar months · exact 3 months ---');
      debugPrint('result            : $result');

      expect(result, [3, 0]);
    });

    test('exact 12 months → [12, 0]', () {
      final result = DateUtils.getCalendarMonthsAndRemainingDays(
        start: DateTime(2025, 3, 1),
        end: DateTime(2026, 3, 1),
      );

      expect(result, [12, 0]);
    });

    test('Jan 31 → Feb 28 (non-leap) clamped to [1, 0]', () {
      final result = DateUtils.getCalendarMonthsAndRemainingDays(
        start: DateTime(2026, 1, 31),
        end: DateTime(2026, 2, 28),
      );

      debugPrint('--- calendar months · Jan31→Feb28 clamp ---');
      debugPrint('result            : $result');

      expect(result, [1, 0]);
    });

    test('Jan 31 → Feb 29 (leap 2024) clamped to [1, 0]', () {
      final result = DateUtils.getCalendarMonthsAndRemainingDays(
        start: DateTime(2024, 1, 31),
        end: DateTime(2024, 2, 29),
      );

      expect(result, [1, 0]);
    });

    test('Mar 31 → Apr 30 clamped to [1, 0]', () {
      final result = DateUtils.getCalendarMonthsAndRemainingDays(
        start: DateTime(2026, 3, 31),
        end: DateTime(2026, 4, 30),
      );

      expect(result, [1, 0]);
    });

    test('only days, no full month → [0, days]', () {
      final result = DateUtils.getCalendarMonthsAndRemainingDays(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 16),
      );

      debugPrint('--- calendar months · 15 days only ---');
      debugPrint('result            : $result');

      expect(result, [0, 15]);
    });

    test('cross-year: Dec 1 → Mar 1 → [3, 0]', () {
      final result = DateUtils.getCalendarMonthsAndRemainingDays(
        start: DateTime(2025, 12, 1),
        end: DateTime(2026, 3, 1),
      );

      debugPrint('--- calendar months · cross year ---');
      debugPrint('result            : $result');

      expect(result, [3, 0]);
    });
  });
}
