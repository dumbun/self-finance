import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:screenshot/screenshot.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/logic/logic.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/payment_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history.dart';
import 'package:self_finance/providers/app_currency_provider.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/providers/history_provider.dart';
import 'package:self_finance/providers/items_provider.dart';
import 'package:self_finance/providers/requried_payments_provider.dart';
import 'package:self_finance/providers/requried_transaction_provider.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
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

class TransactionDetailView extends StatelessWidget {
  TransactionDetailView({super.key, required this.transacrtion, required this.customerDetails});

  final Trx transacrtion;
  final Customer customerDetails;

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

  Card _buildDateCards(List<Payment> payments) {
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

        return ref.watch(asyncRequriedTransactionsProvider(transacrtion.id!)).when(
              data: (List<Trx> data) {
                final LoanCalculator calculator = LoanCalculator(
                  rateOfInterest: data.first.intrestRate,
                  takenAmount: data.first.amount,
                  takenDate: data.first.transacrtionDate,
                  tenureDate: payments.isNotEmpty ? DateTime.tryParse(payments.first.paymentDate) : DateTime.now(),
                );

                return Expanded(
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
                      SizedBox(height: 12.sp),
                      if (data.first.transacrtionType == Constant.active)
                        _buildActionButton(
                          onPressed: () => _markAsPaid(ref, data.first),
                          icon: Icons.done,
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

  void _markAsPaid(
    WidgetRef ref,
    Trx transaction,
  ) async {
    final DateTime presentDate = DateTime.now();
    await ref.read(AsyncRequriedPaymentProvider(transaction.id!).notifier).addPayment(
          payment: Payment(
            transactionId: transaction.id!,
            paymentDate: presentDate.toIso8601String(),
            amountpaid: transaction.amount,
            type: 'cash',
            createdDate: DateTime.now().toIso8601String(),
          ),
        );
    await ref
        .read(asyncRequriedTransactionsProvider(transaction.id!).notifier)
        .markAsPaidTransaction(trancationId: transaction.id!);
    final List<Customer> c = await ref
        .watch(asyncCustomersProvider.notifier)
        .fetchRequriedCustomerDetails(customerID: transaction.customerId);
    await ref.read(asyncHistoryProvider.notifier).addHistory(
          history: UserHistory(
            userID: 1, //default
            customerID: transaction.customerId,
            itemID: transaction.itemId,
            customerNumber: c.first.number,
            customerName: c.first.name,
            transactionID: transaction.id!,
            eventDate: Utility.presentDate().toString(),
            eventType: Constant.credit,
            amount: transaction.amount,
          ),
        );
  }

  _buildActionButton({
    required void Function() onPressed,
    required IconData icon,
    required String text,
  }) {
    return RoundedCornerButton(
      onPressed: onPressed,
      icon: icon,
      text: text,
    );
  }

  Card _buildCustomerDetails() {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 20.sp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyTwoDefaultText(
                  text: customerDetails.name,
                  bold: true,
                ),
                BodyTwoDefaultText(
                  text: customerDetails.number,
                  color: AppColors.getLigthGreyColor,
                ),
                BodyTwoDefaultText(
                  text: customerDetails.address,
                  color: AppColors.getLigthGreyColor,
                ),
              ],
            ),
            CircularImageWidget(
              imageData: customerDetails.photo,
              titile: "${customerDetails.name} photo",
            ),
          ],
        ),
      ),
    );
  }

  final ScreenshotController screenShotController = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenShotController,
      child: Scaffold(
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
        body: Container(
          padding: EdgeInsets.all(12.sp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerDetails(),
              SizedBox(height: 12.sp),
              const BodyOneDefaultText(
                text: 'Transaction Details',
                bold: true,
              ),
              _buildTransactionDetails(screenShotController),
            ],
          ),
        ),
      ),
    );
  }
}
