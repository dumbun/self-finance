import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/fonts/title_widget.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/slidable_widget.dart';

class CustomerTransactionsWidget extends ConsumerWidget {
  const CustomerTransactionsWidget({
    super.key,
    required this.customerId,
    this.shrinkWrap = false,
    this.physics,
  });

  final String customerId;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ref.watch(requriedCustomerTransactionsProvider(customerId)).when(
      data: (List<Trx?> transactions) {
        final List<Trx> list = transactions.whereType<Trx>().toList();

        if (list.isNotEmpty) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shrinkWrap: shrinkWrap,
            physics: physics ?? const AlwaysScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              final Trx transaction = list[index];
              final bool isActive =
                  transaction.transacrtionType == Constant.active;

              return SlidableWidget(
                transactionId: transaction.id!,
                customerId: transaction.customerId,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Routes.navigateToTransactionDetailsView(
                      transacrtionId: transaction.id!,
                      customerId: customerId,
                      context: context,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row: Status pill + Transaction ID
                          Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.getGreenColor.withValues(
                                        alpha: 0.14,
                                      )
                                    : AppColors.getLigthGreyColor.withValues(
                                        alpha: 0.14,
                                      ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isActive
                                          ? AppColors.getGreenColor
                                          : AppColors.getLigthGreyColor,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  BodySmallText(
                                    text: isActive
                                        ? l10n.active.toUpperCase()
                                        : l10n.completed.toUpperCase(),
                                    bold: true,
                                    color: isActive
                                        ? AppColors.getGreenColor
                                        : AppColors.getLigthGreyColor,
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.getLigthGreyColor
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: BodySmallText(
                                  text: "ID: #${transaction.id}",
                                  bold: true,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  color: AppColors.getLigthGreyColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Middle row: Principal Amount & Rate
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                              child: CurrencyWidget(
                                amount: Utility.doubleFormate(
                                  transaction.amount,
                                ),
                                titleText: true,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.getPrimaryColor.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.percent_rounded,
                                    size: 13,
                                    color: AppColors.getPrimaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  BodySmallText(
                                    text: "${transaction.intrestRate}% / mo",
                                    bold: true,
                                    color: AppColors.getPrimaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Divider(
                          height: 1,
                          color: AppColors.getLigthGreyColor
                              .withValues(alpha: 0.15),
                        ),
                        const SizedBox(height: 10),

                        // Footer row: Dates & Arrow
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: AppColors.getLigthGreyColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: BodySmallText(
                                text:
                                    "${l10n.takenDate}: ${Utility.formatDate(date: transaction.transacrtionDate)}",
                                color: AppColors.getLigthGreyColor,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.getLigthGreyColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }

        // Empty state
        return Center(
          child: SingleChildScrollView(
            physics: physics ?? const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.getPrimaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: AppColors.getPrimaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                TitleWidget(
                  text: l10n.noTransactionsFound,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                BodySmallText(
                  text: l10n.customerNoTransactionsRecorded,
                  textAlign: TextAlign.center,
                  color: AppColors.getLigthGreyColor,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () =>
                      Routes.navigateToAddNewTransactionToCustomerView(
                    context: context,
                    customerID: customerId,
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: BodyTwoDefaultText(
                    text: l10n.createFirstTransaction,
                    bold: true,
                    color: Colors.white,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.getPrimaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BodyOneDefaultText(
            error: true,
            text: l10n.errorFetchingTransactions,
          ),
        ),
      ),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator.adaptive(),
        ),
      ),
    );
  }
}
