import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/logic/logic.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/payment_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/requried_payments_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/pawned_item_image_widget.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

class TransactionDetailsWidget extends ConsumerWidget {
  const TransactionDetailsWidget({super.key, required this.transactionId});
  final int transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Trx>> transactionAsync = ref.watch(
      fetchRequriedTransactionProvider(transactionId),
    );
    final List<Payment> payments = ref.watch(
      requriedPaymentsProvider(transactionId),
    );

    void showSignature(String signaturePath) {
      try {
        final file = File(signaturePath);
        if (!file.existsSync()) {
          SnackBarWidget.snackBarWidget(
            context: context,
            message: 'Signature file not found',
          );
          return;
        }

        Routes.navigateToImageView(
          context: context,
          imageWidget: Image.file(file),
          titile: "Signature",
        );
      } catch (e) {
        SnackBarWidget.snackBarWidget(
          context: context,
          message: 'Error loading signature: ${e.toString()}',
        );
      }
    }

    Column buildDate(String eventDate) {
      try {
        final date = DateTime.parse(eventDate);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            BodyTwoDefaultText(
              text: DateFormat('dd-MM-yyyy').format(date),
              bold: true,
            ),
            BodyTwoDefaultText(text: DateFormat.Hm().format(date)),
          ],
        );
      } catch (e) {
        debugPrint('Error parsing date: $e');
        return Column(
          children: [BodyTwoDefaultText(text: eventDate, bold: true)],
        );
      }
    }

    Card buildCard({
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
              ? CurrencyWidget(color: trailingIconColor, amount: data)
              : BodyTwoDefaultText(
                  text: data,
                  bold: true,
                  color: trailingIconColor,
                ),
        ),
      );
    }

    return transactionAsync.when(
      data: (List<Trx> data) {
        if (data.isEmpty) {
          return const Expanded(
            child: Center(
              child: BodyTwoDefaultText(
                text: 'No transaction found',
                bold: true,
              ),
            ),
          );
        }

        final transaction = data.first;

        final DateTime tenureDate = payments.isNotEmpty
            ? DateTime.tryParse(payments.first.paymentDate) ?? DateTime.now()
            : DateTime.now();

        final LoanCalculator loanCalculator = LoanCalculator(
          rateOfInterest: transaction.intrestRate,
          takenAmount: transaction.amount,
          takenDate: transaction.transacrtionDate,
          tenureDate: tenureDate,
        );

        return Expanded(
          child: ListView(
            children: [
              // Transaction ID
              buildCard(
                title: 'Transaction ID',
                data: transaction.id?.toString() ?? 'N/A',
                icon: Icons.numbers,
              ),

              // Transaction Status
              buildCard(
                title: Constant.transactionStatus,
                data: transaction.transacrtionType == Constant.active
                    ? Constant.active
                    : Constant.inactive,
                icon: Icons.online_prediction,
                trailingIcon: Icons.circle,
                trailingIconColor:
                    transaction.transacrtionType == Constant.active
                    ? AppColors.getGreenColor
                    : AppColors.getErrorColor,
              ),

              // Taken Date
              buildCard(
                title: Constant.takenDate,
                data: transaction.transacrtionDate,
                icon: Icons.calendar_month_rounded,
              ),

              // Payment Date or Present Date
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_month_rounded),
                  title: BodyTwoDefaultText(
                    text: payments.isNotEmpty ? 'Payment Date' : 'Present Date',
                    bold: true,
                  ),
                  trailing: payments.isNotEmpty
                      ? buildDate(payments.first.paymentDate)
                      : BodyTwoDefaultText(
                          bold: true,
                          text: DateFormat('dd-MM-yyyy').format(DateTime.now()),
                        ),
                ),
              ),

              // Number of Due Dates
              buildCard(
                title: "No.Due Dates",
                data: loanCalculator.monthsAndRemainingDays,
                icon: Icons.timer,
              ),

              // Taken Amount
              buildCard(
                currency: true,
                title: Constant.takenAmount,
                data: Utility.doubleFormate(transaction.amount),
                icon: Icons.arrow_upward_rounded,
                trailingIconColor: AppColors.getErrorColor,
              ),

              // Rate Of Interest
              buildCard(
                title: Constant.rateOfIntrest,
                data: '${transaction.intrestRate.toString()} %',
                icon: Icons.percent,
                trailingIconColor: AppColors.contentColorCyan,
              ),

              // Interest Per Month
              buildCard(
                currency: true,
                title: 'Interest Per Month',
                data: Utility.doubleFormate(loanCalculator.interestPerDay * 30),
                icon: Icons.timeline,
                trailingIconColor: AppColors.getPrimaryColor,
              ),

              // Total Interest Amount
              buildCard(
                currency: true,
                title: 'Total Interest Amount',
                data: Utility.doubleFormate(loanCalculator.totalInterestAmount),
                icon: Icons.assignment_turned_in_outlined,
                trailingIconColor: AppColors.getPrimaryColor,
              ),

              // Total Amount
              buildCard(
                currency: true,
                title: 'Total Amount',
                data: Utility.doubleFormate(loanCalculator.totalAmount),
                icon: Icons.arrow_downward_rounded,
                trailingIconColor: AppColors.contentColorGreen,
              ),

              // Pawned Item Image
              PawnedItemImageWidget(itemID: transaction.itemId),

              // Signature
              if (transaction.signature.isNotEmpty)
                buildCard(
                  onTap: () => showSignature(transaction.signature),
                  title: "Signature",
                  data: "Show",
                  icon: Icons.topic_outlined,
                  trailingIcon: Icons.app_registration_sharp,
                ),

              SizedBox(height: 12.sp),
            ],
          ),
        );
      },
      error: (Object error, StackTrace stackTrace) {
        debugPrint('Error: $error\n$stackTrace');
        return Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                BodyTwoDefaultText(
                  text: 'Error loading transaction details',
                  bold: true,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    ref.invalidate(
                      fetchRequriedTransactionProvider(transactionId),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Expanded(
        child: Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
