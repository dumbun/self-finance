import 'package:intl/intl.dart';

class LoanCalculator {
  final double takenAmount;
  final double rateOfInterest;
  final String takenDate;
  DateTime? tenureDate;

  ///The [LoanCalculator] class is a Dart implementation for calculating loan-related metrics such as the number of days between the loan initiation date and a specified tenure date, the equivalent duration in months and remaining days, the daily interest rate, the total interest accrued, and the overall amount payable.

  /// Class Structure:

  /// Properties:
  ///- `takenAmount`: The principal amount of the loan.
  ///- `rateOfInterest`: The annual interest rate as a percentage.
  ///- `takenDate`: The date when the loan was initiated in the format "dd-MM-yyyy".
  ///- `tenureDate`: The optional date representing the tenure end date.

  /// Methods:
  ///1. `getDays()`: Calculates the number of days between the loan initiation date and the tenure date (current date if tenure date is not provided).

  ///2. `daysToMonthsAndRemainingDays()`: Converts the total days into months and remaining days, providing a human-readable representation.

  ///3. `getInterestPerDay()`: Calculates the daily interest rate based on the annual interest rate.

  ///4. `totalInterest()`: Computes the total interest accrued by multiplying the daily interest rate with the total number of days.

  ///5. `getTotal()`: Calculates the total amount payable, including the principal amount and the total interest.

  /// Getter Properties:
  ///- `days`: A getter property providing the total number of days.
  ///- `monthsAndRemainingDays`: A getter property offering a formatted string of months and remaining days.
  ///- `interestPerDay`: A getter property providing the daily interest rate.
  ///- `totalInterestAmount`: A getter property offering the total interest accrued.
  ///- `totalAmount`: A getter property providing the overall amount payable.

  /// Supporting Class:

  /// `DateUtils`:
  ///A utility class with a static method (`getDaysDifference`) to calculate the difference in days between two given dates.

  /// Usage:
  ///To use the `LoanCalculator`, instantiate an object with the required parameters (principal amount, interest rate, and initiation date). Optionally, provide a tenure date. Access the desired metrics using the provided getter properties or methods. The class aims to enhance code modularity and readability while efficiently handling date-related calculations.

  LoanCalculator({
    required this.takenAmount,
    required this.rateOfInterest,
    required this.takenDate,
    this.tenureDate,
  });

  int get days => _getDays();
  String get monthsAndRemainingDays => _daysToMonthsAndRemainingDays();
  double get interestPerDay => _getInterestPerDay();
  double get totalInterestAmount => _totalInterest();
  double get totalAmount => _getTotal();

  int _getDays() {
    tenureDate ??= DateTime.now();
    return DateUtils._getDaysDifference(takenDate, tenureDate!);
  }

  String _daysToMonthsAndRemainingDays() {
    int days = _getDays();
    return "${(days ~/ 30)} Months - ${days % 30} Days";
  }

  double _getInterestPerDay() {
    final num perMonth = takenAmount * (rateOfInterest / 100);
    return perMonth / 30;
  }

  double _totalInterest() {
    final double interestPerDay = _getInterestPerDay();
    final int totalDays = _getDays();
    return interestPerDay * totalDays;
  }

  double _getTotal() {
    final double interestPerDay = _getInterestPerDay();
    final int totalDays = _getDays();
    return takenAmount + interestPerDay * totalDays;
  }
}

class DateUtils {
  static int _getDaysDifference(String startDate, DateTime endDate) {
    final DateFormat format = DateFormat("dd-MM-yyyy");
    final DateTime convertedStartDate = format.parseStrict(startDate);
    return endDate.difference(convertedStartDate).inDays;
  }
}
