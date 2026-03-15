import 'dart:math';
import 'package:intl/intl.dart';

/// LoanCalculator
///
/// Assumption:
/// [rateOfInterest] is MONTHLY interest percentage.
/// Example:
///   3.0 => 3% per month
class LoanCalculator {
  final double takenAmount;
  final double rateOfInterest;
  final DateTime takenDate;
  final DateTime? tenureDate;
  final bool inclusiveDays;

  const LoanCalculator({
    required this.takenAmount,
    required this.rateOfInterest,
    required this.takenDate,
    this.tenureDate,
    this.inclusiveDays = true,
  }) : assert(takenAmount >= 0, 'takenAmount cannot be negative'),
       assert(rateOfInterest >= 0, 'rateOfInterest cannot be negative');

  DateTime get _startDate => DateUtils.dateOnly(takenDate);
  DateTime get _endDate => DateUtils.dateOnly(tenureDate ?? DateTime.now());

  /// Total counted days between start and end.
  int get days => DateUtils.getDaysDifference(
    startDate: _startDate,
    endDate: _endDate,
    inclusive: inclusiveDays,
  );

  /// [months, remainingDays]
  List<int> get _monthsDays => DateUtils.getCalendarMonthsAndRemainingDays(
    start: _startDate,
    end: _endDate,
  );

  int get months => _monthsDays[0];
  int get remainingDays => _monthsDays[1];

  String get monthsAndRemainingDays => "$months Months - $remainingDays Days";

  /// 3% => 0.03
  double get _monthlyRate => rateOfInterest / 100.0;

  /// Daily rate derived from monthly rate.
  double get _dailyRate => _monthlyRate / 30.0;

  /// Interest for one full month.
  double get interestPerMonth => takenAmount * _monthlyRate;

  /// Interest for one day.
  double get interestPerDay => takenAmount * _dailyRate;

  /// Simple interest only
  double get totalInterestAmount =>
      (months * interestPerMonth) + (remainingDays * interestPerDay);

  /// Principal + simple interest
  double get totalAmount => takenAmount + totalInterestAmount;

  /// Compound amount after full months and remaining days
  double get compoundTotalAmount {
    final amountAfterMonths =
        takenAmount * pow(1 + _monthlyRate, months).toDouble();

    final amountAfterDays =
        amountAfterMonths * pow(1 + _dailyRate, remainingDays).toDouble();

    return amountAfterDays;
  }

  /// Compound interest only
  double get compoundInterestAmount => compoundTotalAmount - takenAmount;

  /// Optional rounded helpers
  double get totalAmountRounded => _roundTo2(totalAmount);
  double get totalInterestAmountRounded => _roundTo2(totalInterestAmount);
  double get compoundTotalAmountRounded => _roundTo2(compoundTotalAmount);
  double get compoundInterestAmountRounded => _roundTo2(compoundInterestAmount);

  static double _roundTo2(double value) =>
      double.parse(value.toStringAsFixed(2));
}

class DateUtils {
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime parseDateOnly(String ddMMyyyy) {
    final formatter = DateFormat('dd-MM-yyyy');
    final parsed = formatter.parseStrict(ddMMyyyy);
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static int getDaysDifference({
    required DateTime startDate,
    required DateTime endDate,
    bool inclusive = true,
  }) {
    final start = dateOnly(startDate);
    final end = dateOnly(endDate);

    if (end.isBefore(start)) return 0;

    int diff = end.difference(start).inDays;
    if (inclusive) diff += 1;
    return diff;
  }

  /// Returns [calendarMonths, remainingDays]
  static List<int> getCalendarMonthsAndRemainingDays({
    required DateTime start,
    required DateTime end,
  }) {
    final s = dateOnly(start);
    final e = dateOnly(end);

    if (e.isBefore(s)) return [0, 0];

    int months = (e.year - s.year) * 12 + (e.month - s.month);
    DateTime candidate = _addCalendarMonthsClamped(s, months);

    if (candidate.isAfter(e)) {
      months--;
      candidate = _addCalendarMonthsClamped(s, months);
    }

    final remainingDays = max(0, e.difference(candidate).inDays);
    return [months, remainingDays];
  }

  static DateTime _addCalendarMonthsClamped(DateTime date, int monthsToAdd) {
    final totalMonths = (date.month - 1) + monthsToAdd;
    final newYear = date.year + (totalMonths ~/ 12);
    final newMonth = (totalMonths % 12) + 1;
    final newDay = min(date.day, _daysInMonth(newYear, newMonth));

    return DateTime(newYear, newMonth, newDay);
  }

  static int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}
