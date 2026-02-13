import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/logic/logic.dart';
import 'package:self_finance/core/utility/Invoice_generator_utility.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history_model.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/providers/history_provider.dart';
import 'package:self_finance/providers/payments_provider.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';
import 'package:self_finance/widgets/transaction_details_widget.dart';

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
            onPressed: () async {
              await InvoiceGenerator.shareInvoice(
                customerID: widget.customerId,
                transactionID: widget.transactionId,
              );
            },
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
            children: <Widget>[
              TransactionDetailsWidget(transactionId: widget.transactionId),
              _buildPaymentButton(),
            ],
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
        .read(asyncPaymentProvider(transaction.id!).notifier)
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
