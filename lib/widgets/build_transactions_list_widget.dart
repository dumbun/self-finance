import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/customer_name_build_widget.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/slidable_widget.dart';
import 'package:self_finance/widgets/status_chip_widget.dart';

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
                shrinkWrap: true, // ← important
                itemCount: data.length, // ← important
                itemBuilder: (BuildContext context, int index) {
                  final Trx txn = data[index];
                  return SlidableWidget(
                    customerId: txn.customerId,
                    transactionId: txn.id!,
                    child: InkWell(
                      onTap: () => Routes.navigateToTransactionDetailsView(
                        transacrtionId: txn.id!,
                        customerId: txn.customerId,
                        context: context,
                      ),

                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(14.sp),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Consumer(
                                  builder:
                                      (
                                        BuildContext context,
                                        WidgetRef ref,
                                        Widget? child,
                                      ) {
                                        final double size = 28.sp;
                                        final int cacheSize =
                                            (size *
                                                    MediaQuery.of(
                                                      context,
                                                    ).devicePixelRatio)
                                                .round();

                                        return ref
                                            .watch(
                                              customerProvider(txn.customerId),
                                            )
                                            .when(
                                              data: (Customer? data) {
                                                if (data == null) {
                                                  return const BodyTwoDefaultText(
                                                    text: Constant
                                                        .errorUpdatingContactMessage,
                                                  );
                                                }
                                                return CircularImageWidget(
                                                  cache: cacheSize,
                                                  customeSize: size,
                                                  imageData: data.photo,
                                                  titile: data.name,
                                                );
                                              },
                                              loading: () => DefaultUserImage(
                                                height: size,
                                                width: size,
                                              ),
                                              error: (_, _) => DefaultUserImage(
                                                height: size,
                                                width: size,
                                              ),
                                            );
                                      },
                                ),
                                SizedBox(width: 16.sp),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CurrencyWidget(
                                      amount: Utility.doubleFormate(txn.amount),
                                    ),
                                    CustomerNameBuildWidget(
                                      customerID: txn.customerId,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BodyTwoDefaultText(
                                  text: txn.transacrtionDate,
                                  bold: true,
                                  color: AppColors.getLigthGreyColor,
                                ),
                                BodyTwoDefaultText(
                                  text: 'ID: ${txn.id.toString()}',
                                  bold: true,
                                  color: AppColors.getLigthGreyColor,
                                ),
                                StatusChipWidget(txn.transacrtionType),
                              ],
                            ),
                          ],
                        ),
                      ),
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
