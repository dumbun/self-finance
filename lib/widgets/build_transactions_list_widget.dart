import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/trx_with_customer_model.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/default_user_image.dart';
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
          data: (List<TrxWithCustomer> data) {
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
                final TrxWithCustomer txn = data[index];
                return SlidableWidget(
                  key: ValueKey(txn.id),
                  customerId: txn.customerId,
                  transactionId: txn.id,
                  child: ListTile(
                    onTap: () => Routes.navigateToTransactionDetailsView(
                      transacrtionId: txn.id,
                      customerId: txn.customerId,
                      context: context,
                    ),
                    // ✅ No per-row DB subscription — photo comes from the JOIN
                    leading: txn.customerPhoto.isNotEmpty
                        ? CircularImageWidget(
                            errorBuilder: const DefaultUserImage(),
                            customeSize: 44,
                            imageData: txn.customerPhoto,
                            titile: txn.customerName,
                          )
                        : const DefaultUserImage(height: 44, width: 44),
                    title: CurrencyWidget(
                      amount: Utility.doubleFormate(txn.amount),
                    ),
                    // ✅ No per-row DB subscription — name comes from the JOIN
                    subtitle: BodySmallText(
                      text: txn.customerName.isNotEmpty
                          ? txn.customerName
                          : 'Unknown',
                      bold: true,
                      overflow: TextOverflow.ellipsis,
                      color: AppColors.getLigthGreyColor,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodySmallText(
                          text: Utility.formatDate(date: txn.transactionDate),
                          bold: true,
                          color: AppColors.getLigthGreyColor,
                        ),
                        StatusChipWidget(
                          smallText: true,
                          status: txn.transactionType,
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
