import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/fonts/title_widget.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history_model.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/customer_image_widget.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';
import 'package:self_finance/widgets/status_chip_widget.dart';

class HistoryDetailedView extends ConsumerWidget {
  const HistoryDetailedView({super.key, required this.history});

  final UserHistory history;

  static final DateFormat _timeFormat = DateFormat.jm();

  String _formatDateTime(DateTime date) {
    return "${DateFormat.yMMMMEEEEd().format(date)} • ${_timeFormat.format(date)}";
  }

  Future<void> _handleShare(BuildContext context, WidgetRef ref) async {
    try {
      if (history.transactionID.isNotEmpty && history.transactionID != '0') {
        try {
          await ref
              .read(transactionByIDProvider(history.transactionID).notifier)
              .shareTransaction();
          return;
        } catch (_) {
          // If invoice sharing fails, fall through to text receipt
        }
      }

      final bool isDebit = history.eventType == Constant.debited;
      final String typeText = isDebit
          ? "Debit (Paid Out)"
          : "Credit (Received)";
      final String formattedAmount =
          '${isDebit ? '-' : '+'} ₹${Utility.doubleFormate(history.amount)}';

      await SharePlus.instance.share(
        ShareParams(
          subject: "Transaction Receipt - ${history.customerName}",
          text:
              "Self Finance - Transaction Receipt\n\n"
              "Customer: ${history.customerName}\n"
              "Contact: ${history.customerNumber}\n"
              "Amount: $formattedAmount\n"
              "Type: $typeText\n"
              "Date: ${_formatDateTime(history.eventDate)}\n"
              "History Reference: #${history.id}",
        ),
      );
    } catch (e) {
      if (context.mounted) {
        SnackBarWidget.snackBarWidget(
          context: context,
          message: "Unable to share receipt: $e",
        );
      }
    }
  }

  void _navigateToContact(BuildContext context) {
    if (history.customerID.isNotEmpty) {
      Routes.navigateToContactDetailsView(
        context,
        customerID: history.customerID,
      );
    } else {
      SnackBarWidget.snackBarWidget(
        context: context,
        message: "No customer profile linked to this record",
      );
    }
  }

  void _navigateToTransaction(
    BuildContext context, {
    String? transactionId,
    String? customerId,
  }) {
    final String txnId = transactionId ?? history.transactionID;
    final String custId = customerId ?? history.customerID;
    if (txnId.isNotEmpty && txnId != '0') {
      Routes.navigateToTransactionDetailsView(
        context: context,
        transacrtionId: txnId,
        customerId: custId,
      );
    } else {
      SnackBarWidget.snackBarWidget(
        context: context,
        message: "No transaction linked to this record",
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDebit = history.eventType == Constant.debited;

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const BodyTwoDefaultText(
          text: "History Details",
          bold: true,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleShare(context, ref),
        icon: const Icon(Icons.share_rounded),
        label: const Text(
          "Share Receipt",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.getPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Amount Card
                _buildHeroAmountCard(
                  context: context,
                  isDebit: isDebit,
                ),
                const SizedBox(height: 16),

                // Linked Customer Card
                _buildCustomerCard(
                  context: context,
                  ref: ref,
                ),
                const SizedBox(height: 16),

                // Linked Transaction / Loan Card
                _buildTransactionSection(
                  context: context,
                  ref: ref,
                ),

                const SizedBox(height: 80), // Padding for extended FAB
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroAmountCard({
    required BuildContext context,
    required bool isDebit,
  }) {
    final Color statusColor = isDebit
        ? AppColors.getErrorColor
        : AppColors.getGreenColor;
    final String statusLabel = isDebit
        ? "PAID OUT (DEBIT)"
        : "RECEIVED (CREDIT)";
    final IconData statusIcon = isDebit
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;
    final String formattedAmount =
        '${isDebit ? '-' : '+'} ${Utility.doubleFormate(history.amount)}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Chip & Category
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 6),
                      BodySmallText(
                        text: statusLabel,
                        bold: true,
                        color: statusColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: history.id ?? ''));
                      HapticFeedback.lightImpact();
                      SnackBarWidget.snackBarWidget(
                        context: context,
                        message: "Reference ID copied to clipboard",
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color:
                            AppColors.getLigthGreyColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: BodySmallText(
                              text: "Reference #${history.id}",
                              bold: true,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              color: AppColors.getLigthGreyColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.copy_rounded,
                            size: 12,
                            color: AppColors.getLigthGreyColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Main Currency Amount Display
            CurrencyWidget(
              titleText: true,
              color: statusColor,
              amount: formattedAmount,
            ),
            const SizedBox(height: 14),
            Divider(
              height: 1,
              color: AppColors.getLigthGreyColor.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 14),

            // Date & Timestamp
            Row(
              children: [
                const Icon(
                  Icons.event_note_rounded,
                  size: 16,
                  color: AppColors.getLigthGreyColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BodySmallText(
                    text: _formatDateTime(history.eventDate),
                    color: AppColors.getLigthGreyColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    final customerAsync = ref.watch(customerProvider(history.customerID));
    final Customer? customer = customerAsync.asData?.value;
    final String displayName =
        customer != null ? customer.name : history.customerName;
    final String displayNumber =
        customer != null ? customer.number : history.customerNumber;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToContact(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 18,
                        color: AppColors.getLigthGreyColor,
                      ),
                      SizedBox(width: 8),
                      BodyTwoDefaultText(
                        text: "Customer Details",
                        bold: true,
                        color: AppColors.getLigthGreyColor,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BodySmallText(
                        text: "View Profile",
                        bold: true,
                        color: AppColors.getPrimaryColor,
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: AppColors.getPrimaryColor,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  CustomerImageWidget(customerId: history.customerID, size: 56),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodyOneDefaultText(
                          text: displayName,
                          bold: true,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_rounded,
                              size: 14,
                              color: AppColors.getLigthGreyColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: BodySmallText(
                                text: displayNumber.isNotEmpty
                                    ? displayNumber
                                    : "No phone number",
                                color: AppColors.getLigthGreyColor,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (displayNumber.isNotEmpty) ...[
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor:
                            AppColors.getPrimaryColor.withValues(alpha: 0.12),
                        foregroundColor: AppColors.getPrimaryColor,
                      ),
                      icon: const Icon(Icons.call_rounded, size: 18),
                      tooltip: "Call Customer",
                      onPressed: () =>
                          Utility.makeCall(phoneNumber: displayNumber),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionSection({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    // 1. If history.transactionID is not empty and not '0', watch that specific transaction
    if (history.transactionID.isNotEmpty && history.transactionID != '0') {
      return ref
          .watch(transactionByIDProvider(history.transactionID))
          .when(
            data: (Trx? trx) {
              if (trx != null) {
                return _buildTransactionCard(
                  context: context,
                  trx: trx,
                );
              }
              return _buildCustomerTransactionsFallback(
                context: context,
                ref: ref,
              );
            },
            loading: _buildLoadingCard,
            error: (_, _) => _buildCustomerTransactionsFallback(
              context: context,
              ref: ref,
            ),
          );
    }

    // 2. If history.transactionID is empty, resolve via customer's transactions
    return _buildCustomerTransactionsFallback(
      context: context,
      ref: ref,
    );
  }

  Widget _buildCustomerTransactionsFallback({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    if (history.customerID.isEmpty) {
      return _buildNoTransactionCard(
        context: context,
      );
    }

    final custTxnsAsync = ref.watch(
      requriedCustomerTransactionsProvider(history.customerID),
    );

    return custTxnsAsync.when(
      data: (List<Trx> txns) {
        if (txns.isNotEmpty) {
          final Trx matchingTrx = txns.firstWhere(
            (t) => t.amount == history.amount,
            orElse: () => txns.first,
          );
          return _buildTransactionCard(
            context: context,
            trx: matchingTrx,
          );
        }
        return _buildNoTransactionCard(
          context: context,
        );
      },
      loading: _buildLoadingCard,
      error: (_, _) => _buildNoTransactionCard(
        context: context,
      ),
    );
  }

  Widget _buildTransactionCard({
    required BuildContext context,
    required Trx trx,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 18,
                      color: AppColors.getLigthGreyColor,
                    ),
                    SizedBox(width: 8),
                    BodyTwoDefaultText(
                      text: "Transaction Details",
                      bold: true,
                      color: AppColors.getLigthGreyColor,
                    ),
                  ],
                ),
                StatusChipWidget(status: trx.transacrtionType),
              ],
            ),
            const SizedBox(height: 16),

            // Loan stats row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BodySmallText(
                        text: "Principal Amount",
                        color: AppColors.getLigthGreyColor,
                      ),
                      const SizedBox(height: 4),
                      CurrencyWidget(amount: Utility.doubleFormate(trx.amount)),
                    ],
                  ),
                ),
                Container(
                  height: 36,
                  width: 1,
                  color: AppColors.getLigthGreyColor.withValues(alpha: 0.2),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BodySmallText(
                        text: "Interest Rate",
                        color: AppColors.getLigthGreyColor,
                      ),
                      const SizedBox(height: 4),
                      TitleWidget(text: "${trx.intrestRate}% / mo"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Transaction Details Action Button
            FilledButton.icon(
              onPressed: () => _navigateToTransaction(
                context,
                transactionId: trx.id ?? history.transactionID,
                customerId: trx.customerId,
              ),
              icon: const Icon(Icons.receipt_long_rounded, size: 18),
              label: const Text(
                "Show Transaction Details",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor:
                    AppColors.getPrimaryColor.withValues(alpha: 0.12),
                foregroundColor: AppColors.getPrimaryColor,
                elevation: 0,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTransactionCard({
    required BuildContext context,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.getLigthGreyColor,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: BodySmallText(
                    text:
                        "No direct loan transaction record linked to this payment.",
                    color: AppColors.getLigthGreyColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => _navigateToTransaction(context),
              icon: const Icon(Icons.receipt_long_rounded, size: 18),
              label: const Text(
                "Show Transaction Details",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor:
                    AppColors.getPrimaryColor.withValues(alpha: 0.12),
                foregroundColor: AppColors.getPrimaryColor,
                elevation: 0,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
