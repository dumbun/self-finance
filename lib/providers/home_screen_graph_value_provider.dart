import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/logic/logic.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/utility/user_utility.dart';

final homeScreenGraphValuesProvider = FutureProvider.autoDispose<Map<String, double>>(
  (ref) async {
    final double totalActiveTakenAmount = await ref.watch(asyncTransactionsProvider.notifier).fetchSumOfTakenAmount();
    final double totalIntrestAmount = await ref.watch(asyncTransactionsProvider).when(
          data: (List<Trx> data) {
            if (data.isEmpty) return 0;
            double intrestAmount = 0;
            for (Trx element in data) {
              if (element.transacrtionType == Constant.active) {
                final l = LoanCalculator(
                  takenAmount: element.amount,
                  rateOfInterest: element.intrestRate,
                  takenDate: element.transacrtionDate,
                );
                intrestAmount = intrestAmount + l.totalInterestAmount;
              }
            }
            return intrestAmount;
          },
          error: (error, stackTrace) => 0,
          loading: () => 0,
        );
    if (totalIntrestAmount != 0.0 || totalActiveTakenAmount != 0.0) {
      final double totolAmount = totalIntrestAmount + totalActiveTakenAmount;
      final double firstIndicatorPercentage = (totalActiveTakenAmount / totolAmount) * 100;
      final double secoundIndicatorPercentage = (totalIntrestAmount / totolAmount) * 100;
      return {
        Constant.firstIndicatorPercentage: Utility.reduceDecimals(firstIndicatorPercentage),
        Constant.secoundIndicatorPercentage: Utility.reduceDecimals(secoundIndicatorPercentage),
      };
    } else {
      return {};
    }
  },
);
