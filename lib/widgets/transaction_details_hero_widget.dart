import 'package:material_ui/material_ui.dart';
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const BodyTwoDefaultText(text: "Transaction ID: "),
                Flexible(
                  child: BodyTwoDefaultText(
                    text: transaction.id.toString(),
                    bold: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                ClipbordWidget(
                  key: ValueKey<String>(transaction.id!),
                  value: transaction.id.toString(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
