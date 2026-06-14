import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/customer_image_widget.dart';
import 'package:self_finance/widgets/customer_name_build_widget.dart';
import 'package:self_finance/widgets/slidable_widget.dart';
import 'package:self_finance/widgets/status_chip_widget.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';

class BuildTransactionsListWidget extends ConsumerWidget {
  const BuildTransactionsListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(transactionsProvider)
        .when(
          data: (List<Trx> data) {
            if (data.isEmpty) {
              return const Center(
                child: BodyOneDefaultText(
                  bold: true,
                  text: "No Transactons to view",
                ),
              );
            }
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                final Trx txn = data[index];
                return SlidableWidget(
                  customerId: txn.customerId,
                  transactionId: txn.id!,
                  child: ListTile(
                    onTap: () => Routes.navigateToTransactionDetailsView(
                      transacrtionId: txn.id!,
                      customerId: txn.customerId,
                      context: context,
                    ),
                    leading: CustomerImageWidget(
                      customerId: txn.customerId,
                      size: 44,
                    ),
                    title: CurrencyWidget(
                      amount: Utility.doubleFormate(txn.amount),
                    ),
                    subtitle: CustomerNameBuildWidget(
                      customerID: txn.customerId,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodySmallText(
                          text: Utility.formatDate(date: txn.transacrtionDate),
                          bold: true,
                          color: AppColors.getLigthGreyColor,
                        ),
                        StatusChipWidget(
                          smallText: true,
                          status: txn.transacrtionType,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          error: (Object error, StackTrace stackTrace) =>
              BodyTwoDefaultText(text: error.toString()),
          loading: () => const CircularProgressIndicator.adaptive(),
        );
  }
}
