import 'package:flutter_riverpod/flutter_riverpod.dart';

final totalAmountProvider = StateProvider.autoDispose<double>((ref) => 0);
final totalIntrestProvider = StateProvider.autoDispose<double>((ref) => 0);
final emiPerMonthProvider = StateProvider.autoDispose<double>((ref) => 0);
final principalAmountProvider = StateProvider.autoDispose<double>((ref) => 0);
final monthsAndDaysProvider = StateProvider.autoDispose<String>((ref) => "");
final firstIndicatorPercentageProvider = StateProvider.autoDispose<double>((ref) => 0);
final secoundIndicatorPercentageProvider = StateProvider.autoDispose<double>((ref) => 0);
