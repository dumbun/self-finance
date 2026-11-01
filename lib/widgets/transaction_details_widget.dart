import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
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
    final l10n = context.l10n;

    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.handshake_rounded),
            title: BodyTwoDefaultText(text: l10n.takenAmount),
            trailing: CurrencyWidget(
              smallText: true,
              amount: Utility.doubleFormate(transaction.amount),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.percent_rounded),
            title: BodyTwoDefaultText(text: l10n.rateOfIntrest),
            trailing: BodyTwoDefaultText(
              bold: true,
              text: transaction.intrestRate.toString(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: BodyTwoDefaultText(text: l10n.takenDate),
            trailing: BodyTwoDefaultText(
              bold: true,
              text: Utility.formatDate(date: transaction.transacrtionDate),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.date_range),
            title: BodyTwoDefaultText(
              text: payment.isEmpty
                  ? l10n.presentDate
                  : l10n.paymentDate,
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
            title: BodyTwoDefaultText(text: l10n.dueDate),
            trailing: BodyTwoDefaultText(
              bold: true,
              text: loanCalculator.monthsAndRemainingDays,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.auto_graph_rounded),
            title: BodyTwoDefaultText(text: l10n.interestPerMonth),
            trailing: CurrencyWidget(
              smallText: true,
              amount: Utility.doubleFormate(loanCalculator.interestPerDay * 30),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.payment_rounded),
            title: BodyTwoDefaultText(text: l10n.totalInterestAmount),
            trailing: CurrencyWidget(
              smallText: true,
              amount: Utility.doubleFormate(loanCalculator.totalInterestAmount),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.handshake_rounded),
            title: BodyTwoDefaultText(text: l10n.totalAmount),
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
