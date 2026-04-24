import 'package:flutter/material.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/widgets/clipbord_widget.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/status_chip_widget.dart';

class TransactionDetailsHeroWidget extends StatelessWidget {
  const TransactionDetailsHeroWidget({
    super.key,
    required this.transaction,
    required this.value,
  });
  final Trx transaction;
  final double value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 36, bottom: 36),
      decoration: BoxDecoration(
        color: transaction.transacrtionType == "Active"
            ? AppColors.contentColorGreen.withAlpha(15)
            : AppColors.getErrorColor.withAlpha(15),
      ),
      child: Column(
        children: <Widget>[
          StatusChipWidget(status: transaction.transacrtionType),
          const SizedBox(height: 12),
          CurrencyWidget(titleText: true, amount: Utility.doubleFormate(value)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const BodyTwoDefaultText(text: "Transaction ID: "),
              BodyTwoDefaultText(text: transaction.id.toString(), bold: true),
              ClipbordWidget(
                key: ValueKey<int>(transaction.id!),
                value: transaction.id.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
