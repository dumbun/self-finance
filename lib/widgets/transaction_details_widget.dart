import 'package:flutter/material.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/logic/logic.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/payment_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/widgets/currency_widget.dart';

class TransactionDetailsWidget extends StatelessWidget {
  const TransactionDetailsWidget({
    super.key,
    required this.transaction,
    required this.payment,
    required this.loanCalculator,
  });
  final Trx transaction;
  final List<Payment> payment;
  final LoanCalculator loanCalculator;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.handshake_rounded),
            title: const BodyTwoDefaultText(text: Constant.takenAmount),
            trailing: CurrencyWidget(
              smallText: true,
              amount: Utility.doubleFormate(transaction.amount),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.percent_rounded),
            title: const BodyTwoDefaultText(text: Constant.rateOfIntrest),
            trailing: BodyTwoDefaultText(
              bold: true,
              text: transaction.intrestRate.toString(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const BodyTwoDefaultText(text: Constant.takenDate),
            trailing: BodyTwoDefaultText(
              bold: true,
              text: Utility.formatDate(date: transaction.transacrtionDate),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.date_range),
            title: BodyTwoDefaultText(
              text: payment.isEmpty
                  ? Constant.presentDate
                  : Constant.paymentDate,
            ),
            trailing: BodyTwoDefaultText(
              bold: true,
              text: payment.isEmpty
                  ? Utility.formatDate(date: DateTime.now())
                  : Utility.formatDate(date: payment.first.paymentDate),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.date_range_rounded),
            title: const BodyTwoDefaultText(text: Constant.duetime),
            trailing: BodyTwoDefaultText(
              bold: true,
              text: loanCalculator.monthsAndRemainingDays,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.auto_graph_rounded),
            title: const BodyTwoDefaultText(text: Constant.intrestPerMonth),
            trailing: CurrencyWidget(
              smallText: true,
              amount: Utility.doubleFormate(loanCalculator.interestPerDay * 30),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.payment_rounded),
            title: const BodyTwoDefaultText(text: Constant.totalIntrestAmount),
            trailing: CurrencyWidget(
              smallText: true,
              amount: Utility.doubleFormate(loanCalculator.totalInterestAmount),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.handshake_rounded),
            title: const BodyTwoDefaultText(text: Constant.totalAmount),
            trailing: CurrencyWidget(
              smallText: true,
              amount: Utility.doubleFormate(loanCalculator.totalAmount),
            ),
          ),
        ],
      ),
    );
  }
}
