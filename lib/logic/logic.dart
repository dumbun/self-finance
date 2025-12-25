import 'package:intl/intl.dart';
import 'dart:math';

/// LoanCalculator: calculates days, calendar months + remaining days,
/// interest per day, total interest, and total payable amount.
///
/// - takenDate must be in "dd-MM-yyyy" format (e.g. "15-12-2024").
/// - tenureDate is optional; if omitted, DateTime.now() is used.
/// - inclusiveDays: if true, day counting includes both start and end days (common for loans).
/// - yearDays: use 365 for calendar-year daily interest, or 360 for banking 30/360 convention.
class LoanCalculator {
  final double takenAmount;
  final double rateOfInterest; // annual rate in percent (e.g. 12.0)
  final String takenDate; // "dd-MM-yyyy"
  final DateTime? tenureDate;
  final bool inclusiveDays;
  final int yearDays;

  const LoanCalculator({
    required this.takenAmount,
    required this.rateOfInterest,
    required this.takenDate,
    this.tenureDate,
    this.inclusiveDays = true,
    this.yearDays = 365,
  });

  /// Total days between takenDate and tenureDate (or now), respecting inclusiveDays.
  int get days => _getDays();

  /// Returns a string like "12 Months - 0 Days" using calendar-month logic.
  String get monthsAndRemainingDays => _getMonthsAndRemainingDaysString();

  /// Interest per day computed as (principal * rate/100) / yearDays
  double get interestPerDay => _getInterestPerDay();

  /// Total interest = interestPerDay * days
  double get totalInterestAmount => _totalInterest();

  /// Total payable = principal + totalInterestAmount
  double get totalAmount => _totalAmount();

  List<int> get _md => DateUtils.getCalendarMonthsAndRemainingDays(
    start: DateUtils.parseDateOnly(takenDate),
    end: tenureDate ?? DateTime.now(),
  );

  // ---------- Internal helpers ----------

  double _totalAmount() {
    return takenAmount + _md[0] * interestPerDay * 30 + _md[1] * interestPerDay;
  }

  int _getDays() {
    final DateTime start = DateUtils.parseDateOnly(takenDate);
    final DateTime end = tenureDate ?? DateTime.now();
    return DateUtils.getDaysDifference(
      startDate: start,
      endDate: end,
      inclusive: inclusiveDays,
    );
  }

  String _getMonthsAndRemainingDaysString() {
    return "${_md[0]} Months - ${_md[1]} Days";
  }

  double _getIntrestPerMonth() {
    return takenAmount * (rateOfInterest / 100.0);
  }

  double _getInterestPerDay() {
    final double annualInterest = _getIntrestPerMonth();
    return annualInterest / 30;
  }

  double _totalInterest() {
    return _md[0] * _getIntrestPerMonth() + _md[1] * _getInterestPerDay();
  }
}

/// Utility functions for date operations.
class DateUtils {
  /// Parse "dd-MM-yyyy" to a DateTime truncated to midnight.
  static DateTime parseDateOnly(String ddMMyyyy) {
    final DateFormat format = DateFormat("dd-MM-yyyy");
    final DateTime parsed = format.parseStrict(ddMMyyyy);
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  /// Return non-negative difference in days between startDate and endDate.
  /// If inclusive is true, both start and end days are counted (add 1).
  /// Returns 0 if endDate < startDate.
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

  /// Returns [months, days] as calendar months + remaining days between start and end.
  /// Example: 15-12-2024 -> 15-12-2025 returns [12, 0].
  /// It assumes end >= start; if end < start it returns [0, 0].
  static List<int> getCalendarMonthsAndRemainingDays({
    required DateTime start,
    required DateTime end,
  }) {
    final DateTime s = DateTime(start.year, start.month, start.day);
    final DateTime e = DateTime(end.year, end.month, end.day);

    if (e.isBefore(s)) return [0, 0];

    // total months ignoring days
    int months = (e.year - s.year) * 12 + (e.month - s.month);

    // candidate = start + months calendar months, with day clipped to month's last day if needed
    DateTime candidate = _addCalendarMonthsClamped(start, months);

    // If candidate is after end, step back one month
    if (candidate.isAfter(e)) {
      months -= 1;
      candidate = _addCalendarMonthsClamped(start, months);
    }

    int remainingDays = e.difference(candidate).inDays;
    if (remainingDays < 0) remainingDays = 0;
    return [months, remainingDays];
  }

  /// Add calendar months to [date], but clamp day to the target month's max day.
  static DateTime _addCalendarMonthsClamped(DateTime date, int monthsToAdd) {
    final int totalMonths = date.month - 1 + monthsToAdd;
    final int newYear = date.year + totalMonths ~/ 12;
    final int newMonth = (totalMonths % 12) + 1;
    final int maxDay = _daysInMonth(newYear, newMonth);
    final int newDay = min(date.day, maxDay);
    return DateTime(newYear, newMonth, newDay);
  }

  static int _daysInMonth(int year, int month) {
    // Dart allows month overflow; day 0 of next month gives last day of current month
    final DateTime lastDay = DateTime(year, month + 1, 0);
    return lastDay.day;
  }

  static int datedifMD({required DateTime start, required DateTime end}) {
    if (end.isBefore(start)) {
      throw ArgumentError('end must be on or after start');
    }

    int daysInMonth(int year, int month) {
      // get first day of next month then step back one day
      final firstOfNext = (month < 12)
          ? DateTime(year, month + 1, 1)
          : DateTime(year + 1, 1, 1);
      return firstOfNext.subtract(const Duration(days: 1)).day;
    }

    // clamp start.day to number of days in end's month to avoid auto-rollover
    final daysInEndMonth = daysInMonth(end.year, end.month);
    final candidateDay = start.day <= daysInEndMonth
        ? start.day
        : daysInEndMonth;
    DateTime temp = DateTime(end.year, end.month, candidateDay);

    // if temp is after end, borrow one month (previous month of end)
    if (temp.isAfter(end)) {
      int prevMonth = end.month - 1;
      int prevYear = end.year;
      if (prevMonth == 0) {
        prevMonth = 12;
        prevYear -= 1;
      }
      final daysInPrev = daysInMonth(prevYear, prevMonth);
      final candidateDayPrev = start.day <= daysInPrev ? start.day : daysInPrev;
      temp = DateTime(prevYear, prevMonth, candidateDayPrev);
    }

    return end.difference(temp).inDays;
  }
}
