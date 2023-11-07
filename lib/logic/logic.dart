import 'package:intl/intl.dart';

class LoanCalculator {
  final int takenAmount;
  final dynamic rateOfInterest;
  final String takenDate;
  DateTime? tenureDate;

  LoanCalculator({
    required this.takenAmount,
    required this.rateOfInterest,
    required this.takenDate,
    this.tenureDate,
  });

  int getDays() {
    tenureDate ??= DateTime.now();

    final DateFormat format = DateFormat("dd-MM-yyyy");
    final DateTime convertedDate = format.parseStrict(takenDate);
    final differenceBetweenDays = tenureDate!.difference(convertedDate).inDays;
    return differenceBetweenDays;
  }

  String daysToMonthsAndRemainingDays() {
    int days = getDays();
    return "${(days ~/ 30)} Months - ${days % 30} Days";
  }

  double getInterestPerDay() {
    final num perMonth = takenAmount * (rateOfInterest / 100);
    final double perDay = perMonth / 30;
    return perDay;
  }

  double totalInterest() {
    final double get = getInterestPerDay();
    final int totalDays = getDays();
    final double totalInterest = get * totalDays;
    return totalInterest;
  }

  double getTotal() {
    int getdays() {
      tenureDate ??= DateTime.now();
      final DateFormat format = DateFormat("dd-MM-yyyy");
      final DateTime convertedDate = format.parseStrict(takenDate);
      final differenceBetweenDays = tenureDate!.difference(convertedDate).inDays;
      return differenceBetweenDays;
    }

    final double interestPerDay = getInterestPerDay();
    final int totalDays = getdays();
    final double totalInterest = interestPerDay * totalDays;
    return takenAmount + totalInterest;
  }
}
