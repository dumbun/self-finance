import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/customer_name_build_widget.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/status_chip_widget.dart';

class BuildTransactionsListWidget extends ConsumerWidget {
  const BuildTransactionsListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(asyncTransactionsProvider)
        .when(
          data: (List<Trx> data) {
            if (data.isNotEmpty) {
              return ListView.builder(
                shrinkWrap: true, // ← important
                itemCount: data.length, // ← important
                itemBuilder: (BuildContext context, int index) {
                  final Trx txn = data[index];
                  return GestureDetector(
                    onTap: () => Routes.navigateToTransactionDetailsView(
                      transacrtionId: txn.id!,
                      customerId: txn.customerId,
                      context: context,
                    ),
                    child: Card(
                      elevation: 0,
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
                                  builder: (context, ref, child) {
                                    final double size = 28.sp;
                                    final int cacheSize =
                                        (size *
                                                MediaQuery.of(
                                                  context,
                                                ).devicePixelRatio)
                                            .round();

                                    return ref
                                        .watch(
                                          customerByIdProvider(txn.customerId),
                                        )
                                        .when(
                                          data: (Customer? data) {
                                            if (data == null ||
                                                data.photo.isEmpty) {
                                              return DefaultUserImage(
                                                height: size,
                                                width: size,
                                              );
                                            }

                                            final file = File(data.photo);
                                            if (!file.existsSync()) {
                                              return DefaultUserImage(
                                                height: size,
                                                width: size,
                                              );
                                            }

                                            return ClipOval(
                                              child: Image.file(
                                                file,
                                                height: size,
                                                width: size,
                                                cacheWidth: cacheSize,
                                                cacheHeight: cacheSize,
                                                fit: BoxFit.cover,
                                              ),
                                            );
                                          },
                                          loading: () => DefaultUserImage(
                                            height: size,
                                            width: size,
                                          ),
                                          error: (_, __) => DefaultUserImage(
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
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const BodyOneDefaultText(
                    bold: true,
                    text: "No Transactons to view",
                  ),
                  Icon(
                    Icons.web_asset_off,
                    size: 80.sp,
                    color: AppColors.getLigthGreyColor,
                  ),
                ],
              );
            }
          },
          error: (Object error, StackTrace stackTrace) =>
              Text(error.toString()),
          loading: () => const CircularProgressIndicator(),
        );
  }
}
