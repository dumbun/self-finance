import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/slidable_widget.dart';

class CustomerTransactionsWidget extends ConsumerWidget {
  const CustomerTransactionsWidget({super.key, required this.customerId});
  final int customerId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(requriedCustomerTransactionsProvider(customerId))
        .when<Widget>(
          data: (List<Trx?> transactions) {
            if (transactions.isNotEmpty) {
              return transactions.isNotEmpty
                  ? ListView.separated(
                      itemCount: transactions.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          SizedBox(height: 12.sp),
                      itemBuilder: (BuildContext context, int index) {
                        final Trx transaction = transactions[index]!;
                        return SlidableWidget(
                          transactionId: transaction.id!,
                          customerId: transaction.customerId,
                          child: Card(
                            child: GestureDetector(
                              onTap: () =>
                                  Routes.navigateToTransactionDetailsView(
                                    transacrtionId: transaction.id!,
                                    customerId: customerId,
                                    context: context,
                                  ),
                              child: Padding(
                                padding: EdgeInsets.all(16.sp),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 24.sp,
                                      color:
                                          transaction.transacrtionType ==
                                              Constant.active
                                          ? AppColors.getGreenColor
                                          : AppColors.getErrorColor,
                                    ),
                                    SizedBox(width: 18.sp),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CurrencyWidget(
                                          amount: Utility.doubleFormate(
                                            transaction.amount,
                                          ),
                                        ),
                                        BodyOneDefaultText(
                                          text:
                                              "${Constant.takenDateSmall}: ${Utility.formatDate(date: transaction.transacrtionDate)}",
                                        ),
                                        BodyOneDefaultText(
                                          text:
                                              "${Constant.rateOfIntrest}: ${transaction.intrestRate}",
                                        ),
                                        BodyTwoDefaultText(
                                          text:
                                              'ID:  ${transaction.id.toString()}',
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
                    )
                  : const Center(
                      child: BodyOneDefaultText(
                        text: Constant.noTransactionMessage,
                      ),
                    );
            } else {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  BodyTwoDefaultText(
                    bold: true,
                    textAlign: TextAlign.center,
                    text: Constant.noTransactionMessage,
                  ),
                  Icon(Icons.arrow_circle_down_rounded, size: 32),
                ],
              );
            }
          },
          error: (Object error, StackTrace stackTrace) => const Center(
            child: BodyOneDefaultText(
              error: true,
              text: Constant.errorFetchingTransactionMessage,
            ),
          ),
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
        );
  }
}
