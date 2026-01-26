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
import 'package:self_finance/models/payment_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history_model.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/providers/history_provider.dart';
import 'package:self_finance/providers/payments_provider.dart';
import 'package:self_finance/providers/requried_payments_provider.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/pawned_item_image_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

class TransactionDetailView extends ConsumerStatefulWidget {
  const TransactionDetailView({
    super.key,
    required this.transactionId,
    required this.customerId,
  });

  final int transactionId;
  final int customerId;

  @override
  ConsumerState<TransactionDetailView> createState() =>
      _TransactionDetailViewState();
}

class _TransactionDetailViewState extends ConsumerState<TransactionDetailView> {
  final ScreenshotController _screenShotController = ScreenshotController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Routes.navigateToContactDetailsView(
              context,
              customerID: widget.customerId,
            ),
            icon: const Icon(Icons.person_3_rounded),
            tooltip: "Show this customer",
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
                _buildPaymentButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentButton() {
    final transactionAsync = ref.watch(
      fetchRequriedTransactionProvider(widget.transactionId),
    );

    return transactionAsync.when(
      data: (List<Trx> data) {
        if (data.isEmpty) {
          return const SizedBox.shrink();
        }

        final transaction = data.first;

        if (transaction.transacrtionType != Constant.active) {
          return const SizedBox.shrink();
        }

        return RoundedCornerButton(
          onPressed: _isProcessing
              ? null
              : () => _handleMarkAsPaid(transaction),
          icon: Icons.done,
          text: _isProcessing ? "Processing..." : "Mark As Paid",
        );
      },
      error: (Object error, StackTrace stackTrace) {
        debugPrint('Error loading transaction: $error');
        return const SizedBox.shrink();
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Future<void> _handleMarkAsPaid(Trx transaction) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final LoanCalculator loanCalculator = LoanCalculator(
        rateOfInterest: transaction.intrestRate,
        takenAmount: transaction.amount,
        takenDate: transaction.transacrtionDate,
        tenureDate: DateTime.now(),
      );

      await _markAsPaid(
        transaction: transaction,
        totalIntrestAmount: loanCalculator.totalInterestAmount,
        totalAmountPaid: loanCalculator.totalAmount,
      );

      if (mounted) {
        SnackBarWidget.snackBarWidget(
          context: context,
          message: 'Transaction marked as paid successfully',
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error marking as paid: $e');
      if (mounted) {
        SnackBarWidget.snackBarWidget(
          context: context,
          message: 'Error: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Column _buildDate(String eventDate) {
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
            ? CurrencyWidget(color: trailingIconColor, amount: data)
            : BodyTwoDefaultText(
                text: data,
                bold: true,
                color: trailingIconColor,
              ),
      ),
    );
  }

  Widget _buildTransactionDetails() {
    final AsyncValue<List<Trx>> transactionAsync = ref.watch(
      fetchRequriedTransactionProvider(widget.transactionId),
    );
    final List<Payment> payments = ref.watch(
      requriedPaymentsProvider(widget.transactionId),
    );

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
              _buildCard(
                title: 'Transaction ID',
                data: transaction.id?.toString() ?? 'N/A',
                icon: Icons.numbers,
              ),

              // Transaction Status
              _buildCard(
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
              _buildCard(
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
                      ? _buildDate(payments.first.paymentDate)
                      : BodyTwoDefaultText(
                          bold: true,
                          text: DateFormat('dd-MM-yyyy').format(DateTime.now()),
                        ),
                ),
              ),

              // Number of Due Dates
              _buildCard(
                title: "No.Due Dates",
                data: loanCalculator.monthsAndRemainingDays,
                icon: Icons.timer,
              ),

              // Taken Amount
              _buildCard(
                currency: true,
                title: Constant.takenAmount,
                data: Utility.doubleFormate(transaction.amount),
                icon: Icons.arrow_upward_rounded,
                trailingIconColor: AppColors.getErrorColor,
              ),

              // Rate Of Interest
              _buildCard(
                title: Constant.rateOfIntrest,
                data: '${transaction.intrestRate.toString()} %',
                icon: Icons.percent,
                trailingIconColor: AppColors.contentColorCyan,
              ),

              // Interest Per Month
              _buildCard(
                currency: true,
                title: 'Interest Per Month',
                data: Utility.doubleFormate(loanCalculator.interestPerDay * 30),
                icon: Icons.timeline,
                trailingIconColor: AppColors.getPrimaryColor,
              ),

              // Total Interest Amount
              _buildCard(
                currency: true,
                title: 'Total Interest Amount',
                data: Utility.doubleFormate(loanCalculator.totalInterestAmount),
                icon: Icons.assignment_turned_in_outlined,
                trailingIconColor: AppColors.getPrimaryColor,
              ),

              // Total Amount
              _buildCard(
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
                _buildCard(
                  onTap: () => _showSignature(transaction.signature),
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
                      fetchRequriedTransactionProvider(widget.transactionId),
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

  void _showSignature(String signaturePath) {
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
      debugPrint('Error showing signature: $e');
      SnackBarWidget.snackBarWidget(
        context: context,
        message: 'Error loading signature: ${e.toString()}',
      );
    }
  }

  Future<void> _markAsPaid({
    required Trx transaction,
    required double totalIntrestAmount,
    required double totalAmountPaid,
  }) async {
    if (transaction.id == null) {
      throw Exception('Transaction ID is null');
    }

    final customers = await ref
        .read(asyncCustomersProvider.notifier)
        .fetchRequriedCustomerDetails(customerID: transaction.customerId);

    if (customers.isEmpty) {
      throw Exception('Customer not found');
    }

    final customer = customers.first;

    await ref
        .read(AsyncPaymentProvider(transaction.id!).notifier)
        .addPayment(amountpaid: totalAmountPaid);

    await ref
        .read(asyncTransactionsProvider.notifier)
        .markAsPaidTransaction(
          trancationId: transaction.id!,
          intrestAmount: totalIntrestAmount,
        );

    await ref
        .read(asyncHistoryProvider.notifier)
        .addHistory(
          history: UserHistory(
            userID: 1,
            customerID: transaction.customerId,
            itemID: transaction.itemId,
            customerNumber: customer.number,
            customerName: customer.name,
            transactionID: transaction.id!,
            eventDate: Utility.presentDate().toString(),
            eventType: Constant.credit,
            amount: totalAmountPaid,
          ),
        );
  }
}
