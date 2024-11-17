import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:screenshot/screenshot.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
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
import 'package:self_finance/utility/image_catch_manager.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/widgets/ads_banner_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

// providers
final requriedTransactionItemProvider = FutureProvider.family.autoDispose<List<Items>, int>((ref, int id) async {
  return await ref.read(asyncItemsProvider.notifier).fetchRequriedItem(itemId: id);
});

final AutoDisposeProviderFamily<List<Payment>, int> paymentsProvider =
    Provider.family.autoDispose<List<Payment>, int>((ref, int transactionId) {
  return ref.watch(asyncRequriedPaymentProvider(transactionId)).when(
        data: (List<Payment> data) => data,
        error: (Object error, StackTrace stackTrace) => [
          Payment(
            transactionId: transactionId,
            paymentDate: 'error',
            amountpaid: 0000,
            type: 'error',
            createdDate: 'error',
          ),
        ],
        loading: () => [
          Payment(
            transactionId: transactionId,
            paymentDate: 'loading',
            amountpaid: 402,
            type: 'loading',
            createdDate: 'loading',
          )
        ],
      );
});

class TransactionDetailView extends StatelessWidget {
  TransactionDetailView({super.key, required this.transacrtion});

  final Trx transacrtion;

  final ScreenshotController _screenShotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: _screenShotController,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.share_rounded,
                color: AppColors.getPrimaryColor,
              ),
              onPressed: () => Utility.screenShotShare(_screenShotController, context),
            ),
          ],
          title: const BodyTwoDefaultText(
            text: Constant.transactionDetails,
            bold: true,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(12.sp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdsBannerWidget(),
                // _buildCustomerDetails(),
                // SizedBox(height: 12.sp),
                // const BodyOneDefaultText(
                //   text: 'Transaction Details',
                //   bold: true,
                // ),
                _buildTransactionDetails(),
              ],
            ),
          ),
        ),
      ),
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
            ? Icon(trailingIcon, color: trailingIconColor ?? AppColors.getPrimaryColor)
            : BodyTwoDefaultText(
                text: data,
                bold: true,
                color: trailingIconColor,
              ),
      ),
    );
  }

  //! Signature button if needed for update
  // FutureBuilder<Directory> _buildShowSignatureButton() {
  //   return FutureBuilder<Directory>(
  //     future: getApplicationDocumentsDirectory(),
  //     builder: (BuildContext context, AsyncSnapshot<Directory> snapshot) {
  //       if (snapshot.hasError) {
  //         return const Text("error");
  //       } else if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const CircularProgressIndicator.adaptive();
  //       } else {
  //         if (File('${snapshot.data!.path}/signature/${transacrtion.id!}.png').existsSync() == true) {
  //           File? f = File('${snapshot.data!.path}/signature/${transacrtion.id!}.png');
  //           return _buildCard(
  //             onTap: () => Routes.navigateToImageView(
  //               context: context,
  //               imageWidget: Image.file(f),
  //               titile: "Signature",
  //             ),
  //             title: "Signature",
  //             data: "",
  //             icon: Icons.topic_outlined,
  //             trailingIcon: Icons.app_registration_sharp,
  //           );
  //         } else {
  //           return const SizedBox.shrink();
  //         }
  //       }
  //     },
  //   );
  // }

  Consumer _buildTransactionDetails() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        // Using ref.read instead of ref.watch for providers that don’t need UI rebuilds.
        final payments = ref.watch(paymentsProvider(transacrtion.id!));
        final appCurrency = ref.read(currencyProvider);

        // Using async provider to fetch transactions
        final asyncTransaction = ref.watch(asyncRequriedTransactionsProvider(transacrtion.id!));

        return asyncTransaction.when(
          data: (List<Trx> data) {
            final transaction = data.first;
            final loanCalculator = LoanCalculator(
              rateOfInterest: transaction.intrestRate,
              takenAmount: transaction.amount,
              takenDate: transaction.transacrtionDate,
              tenureDate: payments.isNotEmpty ? DateTime.tryParse(payments.first.paymentDate) : DateTime.now(),
            );

            return Expanded(
              child: ListView(
                children: [
                  // Transaction Status
                  _buildCard(
                    title: Constant.transactionStatus,
                    data: transaction.transacrtionType == Constant.active ? 'Active' : 'Inactive',
                    icon: Icons.online_prediction,
                    trailingIcon: Icons.circle,
                    trailingIconColor: transaction.transacrtionType == Constant.active
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
                        text: payments.isNotEmpty ? 'Payment Date' : 'Present Date',
                        bold: true,
                      ),
                      trailing: payments.isNotEmpty
                          ? _buildDate(payments.first.paymentDate)
                          : BodyTwoDefaultText(
                              bold: true,
                              text: DateFormat('dd-MM-yyyy').format(DateTime.now()),
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
                    title: Constant.takenAmount,
                    data: '${Utility.doubleFormate(transaction.amount)} $appCurrency',
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
                    title: 'Interest Per Month',
                    data: '${Utility.doubleFormate(loanCalculator.interestPerDay * 30)} $appCurrency',
                    icon: Icons.timeline,
                    trailingIconColor: AppColors.getPrimaryColor,
                  ),

                  // Total Interest Amount Widget
                  _buildCard(
                    title: 'Total Interest Amount',
                    data: '${Utility.doubleFormate(loanCalculator.totalInterestAmount)} $appCurrency',
                    icon: Icons.assignment_turned_in_outlined,
                    trailingIconColor: AppColors.getPrimaryColor,
                  ),

                  // Total Amount Widget
                  _buildCard(
                    title: 'Total Amount',
                    data: '${Utility.doubleFormate(loanCalculator.totalAmount)} $appCurrency',
                    icon: Icons.arrow_downward_rounded,
                    trailingIconColor: AppColors.contentColorGreen,
                  ),

                  // Show Pawned Item Image Widget
                  ref.watch(requriedTransactionItemProvider(transaction.itemId)).when(
                        data: (List<Items> itemData) {
                          return Card(
                            child: ListTile(
                              onTap: () {
                                if (itemData.first.photo.isNotEmpty) {
                                  Routes.navigateToImageView(
                                    context: context,
                                    imageWidget: ImageCacheManager.getCachedImage(itemData.first.photo, 44, 44),
                                    titile: itemData.first.description,
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
                                text: itemData.first.description,
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_rounded,
                                color: AppColors.getPrimaryColor,
                              ),
                            ),
                          );
                        },
                        error: (Object error, StackTrace stackTrace) => const BodyTwoDefaultText(text: Constant.error),
                        loading: () => const Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      ),

                  // show signature image view
                  // _buildShowSignatureButton(),
                  SizedBox(height: 12.sp),

                  // Mark As Paid Button
                  if (transaction.transacrtionType == Constant.active)
                    Hero(
                      tag: Constant.saveButtonTag,
                      child: RoundedCornerButton(
                        onPressed: () => _markAsPaid(ref, transaction, loanCalculator.totalAmount),
                        icon: Icons.done,
                        text: "Mark As Paid",
                      ),
                    ),

                  SizedBox(height: 12.sp),
                ],
              ),
            );
          },
          error: (Object error, StackTrace stackTrace) => BodyTwoDefaultText(text: error.toString()),
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
    double totalAmountPaid,
  ) async {
    final List<Customer> c = await ref
        .read(asyncCustomersProvider.notifier)
        .fetchRequriedCustomerDetails(customerID: transaction.customerId);
    await ref.read(AsyncRequriedPaymentProvider(transaction.id!).notifier).addPayment(amountpaid: transaction.amount);
    await ref
        .read(asyncRequriedTransactionsProvider(transaction.id!).notifier)
        .markAsPaidTransaction(trancationId: transaction.id!);
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
            amount: totalAmountPaid,
          ),
        );
  }

  // Card _buildCustomerDetails() {
  //   return Card(
  //     child: Padding(
  //       padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 20.sp),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: <Widget>[
  //           Column(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               BodyTwoDefaultText(
  //                 text: customerDetails.name,
  //                 bold: true,
  //               ),
  //               BodyTwoDefaultText(
  //                 text: customerDetails.number,
  //                 color: AppColors.getLigthGreyColor,
  //               ),
  //               BodyTwoDefaultText(
  //                 text: customerDetails.address,
  //                 color: AppColors.getLigthGreyColor,
  //               ),
  //             ],
  //           ),
  //           CircularImageWidget(
  //             imageData: customerDetails.photo,
  //             titile: "${customerDetails.name} photo",
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
