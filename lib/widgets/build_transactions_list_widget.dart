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
            if (data.isNotEmpty) {
              return ListView.builder(
                itemCount: data.length, // ← important
                itemBuilder: (BuildContext context, int index) {
                  final Trx txn = data[index];
                  return GestureDetector(
                    onTap: () => Routes.navigateToTransactionDetailsView(
                      transacrtionId: txn.id!,
                      customerId: txn.customerId,
                      context: context,
                    ),
                    child: SlidableWidget(
                      customerId: txn.customerId,
                      transactionId: txn.id!,
                      child: ListTile(
                        key: ValueKey<int?>(txn.id),
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
                              text: Utility.formatDate(
                                date: txn.transacrtionDate,
                              ),
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
                      // child: Padding(
                      //   padding: const EdgeInsets.all(16),
                      //   child: Row(
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Row(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         crossAxisAlignment: CrossAxisAlignment.center,
                      //         children: [
                      //           CustomerImageWidget(
                      //             customerId: txn.customerId,
                      //             size: _size,
                      //           ),
                      //           const SizedBox(width: _height),
                      //           Column(
                      //             mainAxisAlignment: MainAxisAlignment.start,
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: [
                      //               CurrencyWidget(
                      //                 amount: Utility.doubleFormate(txn.amount),
                      //               ),
                      //               CustomerNameBuildWidget(
                      //                 customerID: txn.customerId,
                      //               ),
                      //             ],
                      //           ),
                      //         ],
                      //       ),
                      //       Column(
                      //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           BodySmallText(
                      //             text: Utility.formatDate(
                      //               date: txn.transacrtionDate,
                      //             ),
                      //             bold: true,
                      //             color: AppColors.getLigthGreyColor,
                      //           ),
                      //           BodySmallText(
                      //             text: 'ID: ${txn.id.toString()}',
                      //             bold: true,
                      //             color: AppColors.getLigthGreyColor,
                      //           ),
                      //           StatusChipWidget(
                      //             smallText: true,
                      //             status: txn.transacrtionType,
                      //           ),
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: BodyOneDefaultText(
                  bold: true,
                  text: "No Transactons to view",
                ),
              );
            }
          },
          error: (Object error, StackTrace stackTrace) =>
              BodyTwoDefaultText(text: error.toString()),
          loading: () => const CircularProgressIndicator(),
        );
  }
}
