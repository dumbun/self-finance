import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:screenshot/screenshot.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/logic/logic.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/payment_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/app_currency_provider.dart';
import 'package:self_finance/providers/items_provider.dart';
import 'package:self_finance/providers/requried_payments_provider.dart';
import 'package:self_finance/providers/requried_transaction_provider.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

// providers
final requriedTransactionItemProvider =
    FutureProvider.family.autoDispose<List<Items>, int>((AutoDisposeFutureProviderRef<List<Items>> ref, int id) async {
  final List<Items> responce = await ref.watch(asyncItemsProvider.notifier).fetchRequriedItem(itemId: id);
  return responce;
});

final AutoDisposeProviderFamily<List<Payment>, int> paymentsProvider =
    Provider.family.autoDispose<List<Payment>, int>((AutoDisposeProviderRef<List<Payment>> ref, int transactionId) {
  return ref.watch(asyncRequriedPaymentProvider(transactionId)).when(
        data: (List<Payment> data) => data,
        error: (Object error, StackTrace stackTrace) => [
          Payment(
              transactionId: transactionId, paymentDate: 'error', amountpaid: 0000, type: 'error', createdDate: 'error')
        ],
        loading: () => [
          Payment(
              transactionId: transactionId,
              paymentDate: 'loading',
              amountpaid: 1111,
              type: 'loading',
              createdDate: 'loading')
        ],
      );
});

final class TransactionDetailView extends StatelessWidget {
  TransactionDetailView({super.key, required this.transacrtion});

  final Trx transacrtion;

  Column _buildDate(String eventDate) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        BodyTwoDefaultText(
          text: DateFormat('dd-MM-yyyy').format(DateTime.parse(eventDate)),
          bold: true,
        ),
        BodyTwoDefaultText(
          text: DateFormat.Hm().format(DateTime.parse(eventDate)),
        ),
      ],
    );
  }

  _buildDateCards(List<Payment> payments) {
    if (payments.isNotEmpty) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.calendar_month_rounded),
          title: const BodyTwoDefaultText(
            text: 'Payment Date',
            bold: true,
          ),
          trailing: _buildDate(payments.first.paymentDate),
        ),
      );
    } else {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.calendar_month_rounded),
          title: const BodyTwoDefaultText(
            text: 'Presnt Date',
            bold: true,
          ),
          trailing: BodyTwoDefaultText(
            bold: true,
            text: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          ),
        ),
      );
    }
  }

  Consumer _buildTransactionDetails(ScreenshotController screenShotController) {
    return Consumer(
      builder: (context, ref, child) {
        final List<Payment> payments = ref.watch(paymentsProvider(transacrtion.id!));
        final String appCurrency = ref.watch(currencyProvider);
        final DateTime presentDate = DateTime.now();

        return ref.watch(asyncRequriedTransactionsProvider(transacrtion.id!)).when(
              data: (List<Trx> data) {
                final LoanCalculator calculator = LoanCalculator(
                  rateOfInterest: data.first.intrestRate,
                  takenAmount: data.first.amount,
                  takenDate: data.first.transacrtionDate,
                  tenureDate: payments.isNotEmpty ? DateTime.tryParse(payments.first.paymentDate) : DateTime.now(),
                );

                return Screenshot(
                  controller: screenShotController,
                  child: ListView(
                    children: [
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.online_prediction),
                          title: const BodyTwoDefaultText(
                            text: "Transaction Status",
                            bold: true,
                          ),
                          trailing: Icon(
                            Icons.circle,
                            color: data.first.transacrtionType == Constant.active
                                ? AppColors.getGreenColor
                                : AppColors.getErrorColor,
                          ),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.calendar_month_rounded),
                          title: const BodyTwoDefaultText(
                            text: Constant.takenDate,
                            bold: true,
                          ),
                          trailing: BodyTwoDefaultText(
                            text: data.first.transacrtionDate,
                            bold: true,
                          ),
                        ),
                      ),
                      _buildDateCards(payments),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.timer),
                          title: const BodyTwoDefaultText(
                            text: "No.Due Dates",
                            bold: true,
                          ),
                          trailing: BodyTwoDefaultText(
                            text: calculator.monthsAndRemainingDays,
                            bold: true,
                          ),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.arrow_upward_rounded,
                            color: AppColors.getErrorColor,
                          ),
                          title: const BodyTwoDefaultText(
                            text: Constant.takenAmount,
                            bold: true,
                          ),
                          trailing: BodyTwoDefaultText(
                            text: '${Utility.doubleFormate(data.first.amount)} $appCurrency',
                            bold: true,
                            color: AppColors.getErrorColor,
                          ),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.percent),
                          title: const BodyTwoDefaultText(
                            text: Constant.rateOfIntrest,
                            bold: true,
                          ),
                          trailing: BodyTwoDefaultText(
                            text: '${data.first.intrestRate.toString()} %',
                            bold: true,
                            color: AppColors.contentColorCyan,
                          ),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.timeline),
                          title: const BodyTwoDefaultText(
                            text: 'Intrest Per Month',
                            bold: true,
                          ),
                          trailing: BodyTwoDefaultText(
                            text: '${Utility.doubleFormate(calculator.interestPerDay * 30)} $appCurrency',
                            bold: true,
                            color: AppColors.getPrimaryColor,
                          ),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.assignment_turned_in_outlined),
                          title: const BodyTwoDefaultText(
                            text: 'Total Intrest Amount',
                            bold: true,
                          ),
                          trailing: BodyTwoDefaultText(
                            text: '${Utility.doubleFormate(calculator.totalInterestAmount)} $appCurrency',
                            bold: true,
                            color: AppColors.getPrimaryColor,
                          ),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.arrow_downward_rounded,
                            color: AppColors.getGreenColor,
                          ),
                          title: const BodyTwoDefaultText(
                            text: 'Total Amount',
                            bold: true,
                          ),
                          trailing: BodyTwoDefaultText(
                            text: '${Utility.doubleFormate(calculator.totalAmount)} $appCurrency',
                            bold: true,
                            color: AppColors.getPrimaryColor,
                          ),
                        ),
                      ),
                      ref.watch(requriedTransactionItemProvider(data.first.itemId)).when(
                            data: (data) {
                              return Card(
                                child: ListTile(
                                  onTap: () {
                                    if (data.first.photo.isNotEmpty) {
                                      Routes.navigateToImageView(
                                        context: context,
                                        imageData: data.first.photo,
                                        titile: data.first.description,
                                      );
                                    } else {
                                      SnackBarWidget.snackBarWidget(
                                        context: context,
                                        message: "No Image Found 😔",
                                      );
                                    }
                                  },
                                  leading: const Icon(
                                    Icons.topic_outlined,
                                  ),
                                  title: const BodyTwoDefaultText(
                                    text: 'Show Item',
                                    bold: true,
                                  ),
                                  subtitle: BodyTwoDefaultText(
                                    text: data.first.description,
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: AppColors.getPrimaryColor,
                                  ),
                                ),
                              );
                            },
                            error: (error, stackTrace) => const BodyTwoDefaultText(text: Constant.error),
                            loading: () => const Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          ),
                      if (data.first.transacrtionType == Constant.active)
                        _buildActionButton(
                          onPressed: () async {
                            await ref.read(AsyncRequriedPaymentProvider(data.first.id!).notifier).addPayment(
                                  payment: Payment(
                                    transactionId: data.first.id!,
                                    paymentDate: presentDate.toIso8601String(),
                                    amountpaid: data.first.amount,
                                    type: 'cash',
                                    createdDate: DateTime.now().toIso8601String(),
                                  ),
                                );
                            await ref
                                .read(asyncRequriedTransactionsProvider(data.first.id!).notifier)
                                .markAsPaidTransaction(trancationId: data.first.id!);
                          },
                          icon: const Icon(Icons.done),
                          text: "Mark As Paid",
                        )
                    ],
                  ),
                );
              },
              error: (error, stackTrace) => BodyTwoDefaultText(text: error.toString()),
              loading: () => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            );
      },
    );
  }

  _buildActionButton({
    required void Function()? onPressed,
    required Widget icon,
    required String text,
  }) {
    return ElevatedButton.icon(
      style: const ButtonStyle(elevation: MaterialStatePropertyAll(0)),
      onPressed: onPressed,
      icon: icon,
      label: BodyTwoDefaultText(
        text: text,
      ),
    );
  }

  final ScreenshotController screenShotController = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share_rounded,
              color: AppColors.getPrimaryColor,
            ),
            onPressed: () => Utility.screenShotShare(screenShotController, context),
          ),
        ],
        title: const BodyTwoDefaultText(
          text: "Transaction Details",
          bold: true,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(12.sp),
        child: _buildTransactionDetails(screenShotController),
      ),
    );
  }
}
