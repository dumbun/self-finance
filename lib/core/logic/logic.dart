import 'dart:math';
import 'package:intl/intl.dart';

/// LoanCalculator: calculates calendar months + remaining days,
/// daily interest, total interest, and total payable amount.
///
/// ✅ takenDate is now a DateTime.
/// tenureDate is optional; if omitted, DateTime.now() is used.
class LoanCalculator {
  final double takenAmount;
  final double rateOfInterest; // annual rate in percent (e.g. 12.0)
  final DateTime takenDate;
  final DateTime? tenureDate;

  /// If true, count both start and end day (adds 1 day).
  final bool inclusiveDays;

  const LoanCalculator({
    required this.takenAmount,
    required this.rateOfInterest,
    required this.takenDate,
    this.tenureDate,
    this.inclusiveDays = true,
  });

  /// Total days between takenDate and tenureDate (or now).
  int get days => _getDays();

  /// Example: "3 Months - 12 Days"
  String get monthsAndRemainingDays => _getMonthsAndRemainingDaysString();

  double get interestPerDay => _getInterestPerDay();

  double get totalInterestAmount => _totalInterest();

  double get totalAmount => _totalAmount();

  List<int> get _md => DateUtils.getCalendarMonthsAndRemainingDays(
    start: DateUtils.dateOnly(takenDate),
    end: tenureDate ?? DateTime.now(),
  );

  // ---------------- internal ----------------

  double _totalAmount() {
    // Your original convention: month = 30 days
    return takenAmount + _md[0] * interestPerDay * 30 + _md[1] * interestPerDay;
  }

  int _getDays() {
    final start = DateUtils.dateOnly(takenDate);
    final end = tenureDate ?? DateTime.now();
    return DateUtils.getDaysDifference(
      startDate: start,
      endDate: end,
      inclusive: inclusiveDays,
    );
  }

  String _getMonthsAndRemainingDaysString() {
    return "${_md[0]} Months - ${_md[1]} Days";
  }

  double _getInterestPerMonth() {
    // keep your original formula
    return takenAmount * (rateOfInterest / 100.0);
  }

  double _getInterestPerDay() {
    final monthlyInterest = _getInterestPerMonth();
    return monthlyInterest / 30;
  }

  double _totalInterest() {
    return _md[0] * _getInterestPerMonth() + _md[1] * _getInterestPerDay();
  }
}

class DateUtils {
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Parse "dd-MM-yyyy" -> DateTime (midnight).
  static DateTime parseDateOnly(String ddMMyyyy) {
    final f = DateFormat("dd-MM-yyyy");
    final p = f.parseStrict(ddMMyyyy);
    return DateTime(p.year, p.month, p.day);
  }

  static int getDaysDifference({
    required DateTime startDate,
    required DateTime endDate,
    bool inclusive = true,
  }) {
    int diff = endDate.difference(startDate).inDays;
    if (inclusive) diff += 1;
    if (diff < 0) return 0;
    return diff;
  }

  /// Returns [months, days] using calendar months (not 30-day fixed months).
  static List<int> getCalendarMonthsAndRemainingDays({
    required DateTime start,
    required DateTime end,
  }) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);

    if (e.isBefore(s)) return [0, 0];

    int months = (e.year - s.year) * 12 + (e.month - s.month);
    DateTime candidate = _addCalendarMonthsClamped(s, months);

    if (candidate.isAfter(e)) {
      months -= 1;
      candidate = _addCalendarMonthsClamped(s, months);
    }

    int remainingDays = e.difference(candidate).inDays;
    if (remainingDays < 0) remainingDays = 0;

    return [months, remainingDays];
  }

  static DateTime _addCalendarMonthsClamped(DateTime date, int monthsToAdd) {
    final totalMonths = date.month - 1 + monthsToAdd;
    final newYear = date.year + totalMonths ~/ 12;
    final newMonth = (totalMonths % 12) + 1;
    final maxDay = _daysInMonth(newYear, newMonth);
    final newDay = min(date.day, maxDay);
    return DateTime(newYear, newMonth, newDay);
  }

  static int _daysInMonth(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0);
    return lastDay.day;
  }
}
