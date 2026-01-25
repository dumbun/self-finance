import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:screenshot/screenshot.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/logic/logic.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/payment_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history_model.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/providers/history_provider.dart';
import 'package:self_finance/providers/items_provider.dart';
import 'package:self_finance/providers/payments_provider.dart';
import 'package:self_finance/providers/requried_payments_provider.dart';
import 'package:self_finance/providers/requried_transaction_provider.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/pawned_item_image_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';

// providers
final requriedTransactionItemProvider = FutureProvider.family
    .autoDispose<List<Items>, int>((ref, int id) async {
      return await ref
          .read(asyncItemsProvider.notifier)
          .fetchRequriedItem(itemId: id);
    });

class TransactionDetailView extends StatelessWidget {
  TransactionDetailView({super.key, required this.transacrtion});

  final Trx transacrtion;

  final ScreenshotController _screenShotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Routes.navigateToContactDetailsView(
              context,
              customerID: transacrtion.customerId,
            ),
            icon: Icon(Icons.person_3_rounded),
            tooltip: "Show the customer",
          ),
          IconButton(
            icon: const Icon(
              Icons.share_rounded,
              color: AppColors.getPrimaryColor,
            ),
            onPressed: () =>
                Utility.screenShotShare(_screenShotController, context),
          ),
        ],
        title: const BodyTwoDefaultText(
          text: Constant.transactionDetails,
          bold: true,
        ),
      ),
      body: Screenshot(
        controller: _screenShotController,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(12.sp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildTransactionDetails(),
                _buildPaymentButton(), // Mark As Paid Button
              ],
            ),
          ),
        ),
      ),
    );
  }

  Consumer _buildPaymentButton() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final List<Payment> payments = ref.watch(
          requriedPaymentsProvider(transacrtion.id!),
        );
        final transactionsProvider = ref.watch(
          asyncRequriedTransactionsProvider(transacrtion.id!),
        );
        return transactionsProvider.when(
          data: (List<Trx> data) {
            final transaction = data.first;
            if (transaction.transacrtionType == Constant.active) {
              final loanCalculator = LoanCalculator(
                rateOfInterest: transaction.intrestRate,
                takenAmount: transaction.amount,
                takenDate: transaction.transacrtionDate,
                tenureDate: payments.isNotEmpty
                    ? DateTime.tryParse(payments.first.paymentDate)
                    : DateTime.now(),
              );
              return RoundedCornerButton(
                onPressed: () => _markAsPaid(
                  ref: ref,
                  transaction: transaction,
                  totalIntrestAmount: loanCalculator.totalInterestAmount,
                  totalAmountPaid: loanCalculator.totalAmount,
                ),
                icon: Icons.done,
                text: "Mark As Paid",
              );
            } else {
              return SizedBox.shrink();
            }
          },
          error: (Object error, StackTrace stackTrace) =>
              BodyTwoDefaultText(text: error.toString()),
          loading: () => Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

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

  Card _buildCard({
    required String title,
    required String data,
    required IconData icon,
    bool currency = false,
    Color? color,
    IconData? trailingIcon,
    Color? trailingIconColor,
    void Function()? onTap,
  }) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: BodyTwoDefaultText(text: title, bold: true),
        trailing: trailingIcon != null
            ? Icon(
                trailingIcon,
                color: trailingIconColor ?? AppColors.getPrimaryColor,
              )
            : currency
            ? SizedBox(
                width: 50.sp,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    BodyTwoDefaultText(
                      text: data,
                      bold: true,
                      color: trailingIconColor,
                    ),
                    CurrencyWidget(color: trailingIconColor),
                  ],
                ),
              )
            : BodyTwoDefaultText(
                text: data,
                bold: true,
                color: trailingIconColor,
              ),
      ),
    );
  }

  Consumer _buildTransactionDetails() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        // Using ref.read instead of ref.watch for providers that don’t need UI rebuilds.
        final payments = ref.watch(requriedPaymentsProvider(transacrtion.id!));

        // Using async provider to fetch transactions
        final asyncTransaction = ref.watch(
          asyncRequriedTransactionsProvider(transacrtion.id!),
        );

        return asyncTransaction.when(
          data: (List<Trx> data) {
            final transaction = data.first;
            final LoanCalculator loanCalculator = LoanCalculator(
              rateOfInterest: transaction.intrestRate,
              takenAmount: transaction.amount,
              takenDate: transaction.transacrtionDate,
              tenureDate: payments.isNotEmpty
                  ? DateTime.tryParse(payments.first.paymentDate)
                  : DateTime.now(),
            );

            return Expanded(
              child: ListView(
                children: [
                  // # ID
                  _buildCard(
                    title: 'Transaction ID',
                    data: transaction.id.toString(),
                    icon: Icons.numbers,
                  ),

                  // Transaction Status
                  _buildCard(
                    title: Constant.transactionStatus,
                    data: transaction.transacrtionType == Constant.active
                        ? 'Active'
                        : 'Inactive',
                    icon: Icons.online_prediction,
                    trailingIcon: Icons.circle,
                    trailingIconColor:
                        transaction.transacrtionType == Constant.active
                        ? AppColors.getGreenColor
                        : AppColors.getErrorColor,
                  ),

                  // Taken Date Widget
                  _buildCard(
                    title: Constant.takenDate,
                    data: transaction.transacrtionDate,
                    icon: Icons.calendar_month_rounded,
                  ),

                  // Payment Date or Present Date Widget
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_month_rounded),
                      title: BodyTwoDefaultText(
                        text: payments.isNotEmpty
                            ? 'Payment Date'
                            : 'Present Date',
                        bold: true,
                      ),
                      trailing: payments.isNotEmpty
                          ? _buildDate(payments.first.paymentDate)
                          : BodyTwoDefaultText(
                              bold: true,
                              text: DateFormat(
                                'dd-MM-yyyy',
                              ).format(DateTime.now()),
                            ),
                    ),
                  ),

                  // Number of Due Dates Widget
                  _buildCard(
                    title: "No.Due Dates",
                    data: loanCalculator.monthsAndRemainingDays,
                    icon: Icons.timer,
                  ),

                  // Taken Amount Widget
                  _buildCard(
                    currency: true,
                    title: Constant.takenAmount,
                    data: '${Utility.doubleFormate(transaction.amount)} ',
                    icon: Icons.arrow_upward_rounded,
                    trailingIconColor: AppColors.getErrorColor,
                  ),

                  // Rate Of Interest Widget
                  _buildCard(
                    title: Constant.rateOfIntrest,
                    data: '${transaction.intrestRate.toString()} %',
                    icon: Icons.percent,
                    trailingIconColor: AppColors.contentColorCyan,
                  ),

                  // Interest Per Month Widget
                  _buildCard(
                    currency: true,
                    title: 'Interest Per Month',
                    data:
                        '${Utility.doubleFormate(loanCalculator.interestPerDay * 30)} ',
                    icon: Icons.timeline,
                    trailingIconColor: AppColors.getPrimaryColor,
                  ),

                  // Total Interest Amount Widget
                  _buildCard(
                    currency: true,
                    title: 'Total Interest Amount',
                    data:
                        '${Utility.doubleFormate(loanCalculator.totalInterestAmount)} ',
                    icon: Icons.assignment_turned_in_outlined,
                    trailingIconColor: AppColors.getPrimaryColor,
                  ),

                  // Total Amount Widget
                  _buildCard(
                    currency: true,
                    title: 'Total Amount',
                    data:
                        '${Utility.doubleFormate(loanCalculator.totalAmount)} ',
                    icon: Icons.arrow_downward_rounded,
                    trailingIconColor: AppColors.contentColorGreen,
                  ),

                  // Show Pawned Item Image Widget
                  PawnedItemImageWidget(itemID: transaction.itemId),

                  // show signature image view
                  transaction.signature.isNotEmpty
                      ? _buildCard(
                          onTap: () => Routes.navigateToImageView(
                            context: context,
                            imageWidget: Image.file(
                              File(transaction.signature),
                            ),
                            titile: "Signature",
                          ),
                          title: "Signature",
                          data: "Show",
                          icon: Icons.topic_outlined,
                          trailingIcon: Icons.app_registration_sharp,
                        )
                      : SizedBox.shrink(),
                  SizedBox(height: 12.sp),
                ],
              ),
            );
          },
          error: (Object error, StackTrace stackTrace) =>
              BodyTwoDefaultText(text: error.toString()),
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
        );
      },
    );
  }

  void _markAsPaid({
    required WidgetRef ref,
    required Trx transaction,
    required double totalIntrestAmount,
    required double totalAmountPaid,
  }) async {
    final List<Customer> c = await ref
        .read(asyncCustomersProvider.notifier)
        .fetchRequriedCustomerDetails(customerID: transaction.customerId);
    await ref
        .read(AsyncPaymentProvider(transaction.id!).notifier)
        .addPayment(amountpaid: totalAmountPaid);
    await ref
        .read(asyncRequriedTransactionsProvider(transaction.id!).notifier)
        .markAsPaidTransaction(
          trancationId: transaction.id!,
          intrestAmount: totalIntrestAmount,
        );
    await ref
        .read(asyncHistoryProvider.notifier)
        .addHistory(
          history: UserHistory(
            userID: 1, //default
            customerID: transaction.customerId,
            itemID: transaction.itemId,
            customerNumber: c.first.number,
            customerName: c.first.name,
            transactionID: transaction.id!,
            eventDate: Utility.presentDate().toString(),
            eventType: Constant.credit,
            amount: totalAmountPaid,
          ),
        );
  }
}
