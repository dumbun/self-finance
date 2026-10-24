import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/fonts/strong_heading_one_text.dart';
import 'package:self_finance/core/fonts/title_widget.dart';
import 'package:self_finance/core/logic/logic.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/payment_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/providers/item_provider.dart';
import 'package:self_finance/providers/payment_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/image_widget.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

class TransactionDetailView extends ConsumerStatefulWidget {
  const TransactionDetailView({super.key, required this.transactionId});
  final int transactionId;

  @override
  ConsumerState<TransactionDetailView> createState() =>
      _TransactionDetailViewState();
}

class _TransactionDetailViewState extends ConsumerState<TransactionDetailView>
    with SingleTickerProviderStateMixin {
  bool _isProcessingPayment = false;
  bool _isCompound = false;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleMarkAsPaid({
    required double totalAmount,
    required double interestAmount,
    required bool isCompound,
  }) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        final bool isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: AppColors.getGreenColor),
              SizedBox(width: 10),
              StrongHeadingOne(
                bold: true,
                text: "Settle Transaction?",
              ),
            ],
          ),
          content: BodyTwoDefaultText(
            text:
                "Are you sure you want to mark this transaction as Paid using ${isCompound ? 'Compound' : 'Simple'} interest with total settlement amount of ${Utility.doubleFormate(totalAmount)}?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const BodySmallText(bold: true, text: "Cancel"),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.getGreenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const BodySmallText(
                bold: true,
                color: Colors.white,
                text: "Yes, Mark as Paid",
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isProcessingPayment = true);
    try {
      await ref
          .read(transactionByIDProvider(widget.transactionId).notifier)
          .markAsPaid(
            amountpaid: totalAmount,
            intrestAmount: interestAmount,
          );
      if (mounted) {
        SnackBarWidget.snackBarWidget(
          context: context,
          message: "Transaction marked as Paid successfully ✅",
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarWidget.snackBarWidget(
          context: context,
          message: "Failed to mark as paid: $e",
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingPayment = false);
    }
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    SnackBarWidget.snackBarWidget(context: context, message: message);
  }

  Widget _buildScrollablePlaceholder({required Widget child}) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);

    final String? userCurrency = ref.watch(
      userProvider.select((a) => a.asData?.value?.userCurrency),
    );
    final String currencySymbol =
        (userCurrency != null && userCurrency.isNotEmpty) ? userCurrency : '₹';

    final AsyncValue<Trx?> trxAsync =
        ref.watch(transactionByIDProvider(widget.transactionId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const StrongHeadingOne(
          bold: true,
          text: 'Transaction Details',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "Share Invoice",
            onPressed: () => ref
                .read(transactionByIDProvider(widget.transactionId).notifier)
                .shareTransaction(),
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.getPrimaryColor,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: () async {
            ref.invalidate(
              paymentByTrxIdProvider(transactionId: widget.transactionId),
            );
            ref.invalidate(transactionByIDProvider(widget.transactionId));
            await ref.read(transactionByIDProvider(widget.transactionId).future);
          },
          child: trxAsync.when(
            loading: () => _buildScrollablePlaceholder(
              child: const CircularProgressIndicator.adaptive(),
            ),
            error: (err, _) => _buildScrollablePlaceholder(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BodyTwoDefaultText(
                  bold: true,
                  error: true,
                  text: "Error loading transaction: $err",
                ),
              ),
            ),
            data: (Trx? transaction) {
              if (transaction == null) {
                return _buildScrollablePlaceholder(
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: BodyTwoDefaultText(
                      bold: true,
                      error: true,
                      text: Constant.errorFetchingTransactionMessage,
                    ),
                  ),
                );
              }

              final AsyncValue<List<Payment>> paymentAsync = ref.watch(
                paymentByTrxIdProvider(transactionId: widget.transactionId),
              );

              return paymentAsync.when(
                loading: () => _buildScrollablePlaceholder(
                  child: const CircularProgressIndicator.adaptive(),
                ),
                error: (err, _) => _buildScrollablePlaceholder(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: BodyTwoDefaultText(
                      error: true,
                      text: "Error loading payment history: $err",
                    ),
                  ),
                ),
                data: (List<Payment> payments) {
                  final Payment? settlement =
                      payments.isNotEmpty ? payments.first : null;
                  final bool isPaid = transaction.transacrtionType != Constant.active;

                  final LoanCalculator loanCalc = LoanCalculator(
                    takenAmount: transaction.amount,
                    rateOfInterest: transaction.intrestRate,
                    takenDate: transaction.transacrtionDate,
                    tenureDate: settlement?.paymentDate,
                  );

                  final double activeTotalAmount = _isCompound
                      ? loanCalc.compoundTotalAmount
                      : loanCalc.totalAmount;
                  final double activeInterestAmount = _isCompound
                      ? loanCalc.compoundInterestAmount
                      : loanCalc.totalInterestAmount;

                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Premium Hero Balance Card with Simple/Compound Switcher
                            _HeroBalanceCard(
                              transaction: transaction,
                              loanCalc: loanCalc,
                              isPaid: isPaid,
                              isCompound: _isCompound,
                              settlement: settlement,
                              currencySymbol: currencySymbol,
                              onToggleCompound: (bool value) {
                                setState(() => _isCompound = value);
                              },
                              onCopyId: () => _copyToClipboard(
                                transaction.id.toString(),
                                "Transaction ID copied ✅",
                              ),
                              onShare: () => ref
                                  .read(
                                    transactionByIDProvider(widget.transactionId).notifier,
                                  )
                                  .shareTransaction(),
                            ),

                            const SizedBox(height: 16),

                            // 2. Customer Summary Card
                            _CustomerSummaryCard(
                              customerId: transaction.customerId,
                              isDark: isDark,
                              cardBg: cardBg,
                              borderColor: borderColor,
                            ),

                            const SizedBox(height: 16),

                            // 3. Financial Metrics Grid (Principal, Interest, Duration, Monthly)
                            _MetricsGrid(
                              loanCalc: loanCalc,
                              transaction: transaction,
                              currencySymbol: currencySymbol,
                              isCompound: _isCompound,
                              isDark: isDark,
                              cardBg: cardBg,
                              borderColor: borderColor,
                            ),

                            const SizedBox(height: 16),

                            // 4. Detailed Financial Breakdown Card
                            _BreakdownCard(
                              loanCalc: loanCalc,
                              transaction: transaction,
                              settlement: settlement,
                              isPaid: isPaid,
                              isCompound: _isCompound,
                              currencySymbol: currencySymbol,
                              isDark: isDark,
                              cardBg: cardBg,
                              borderColor: borderColor,
                              onToggleCompound: (bool value) {
                                setState(() => _isCompound = value);
                              },
                            ),

                            const SizedBox(height: 16),

                            // 5. Timeline / Settlement Status Card
                            _TimelineCard(
                              transaction: transaction,
                              settlement: settlement,
                              isPaid: isPaid,
                              currencySymbol: currencySymbol,
                              isDark: isDark,
                              cardBg: cardBg,
                              borderColor: borderColor,
                            ),

                            const SizedBox(height: 16),

                            // 6. Security & Documentation (Pawned Item & Signature)
                            _DocumentationCard(
                              transaction: transaction,
                              isDark: isDark,
                              cardBg: cardBg,
                              borderColor: borderColor,
                            ),

                            const SizedBox(height: 24),

                            // 7. Bottom Settlement / Action Button
                            if (!isPaid)
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: FilledButton.icon(
                                  onPressed: _isProcessingPayment
                                      ? null
                                      : () => _handleMarkAsPaid(
                                            totalAmount: activeTotalAmount,
                                            interestAmount: activeInterestAmount,
                                            isCompound: _isCompound,
                                          ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.getGreenColor,
                                    foregroundColor: Colors.white,
                                    elevation: 3,
                                    shadowColor:
                                        AppColors.getGreenColor.withValues(alpha: 0.4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: _isProcessingPayment
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator.adaptive(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Icon(Icons.check_circle_outline_rounded),
                                  label: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    transitionBuilder: (child, animation) =>
                                        FadeTransition(opacity: animation, child: child),
                                    child: BodyTwoDefaultText(
                                      key: ValueKey<String>(
                                        "btn_${_isCompound}_$_isProcessingPayment",
                                      ),
                                      bold: true,
                                      color: Colors.white,
                                      text: _isProcessingPayment
                                          ? "Processing..."
                                          : "Mark as Paid ($currencySymbol ${Utility.doubleFormate(activeTotalAmount)})",
                                    ),
                                  ),
                                ),
                              )
                            else
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.getGreenColor.withValues(
                                    alpha: isDark ? 0.16 : 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.getGreenColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.verified_rounded,
                                        color: AppColors.getGreenColor,
                                        size: 22,
                                      ),
                                      SizedBox(width: 8),
                                      BodyTwoDefaultText(
                                        bold: true,
                                        color: AppColors.getGreenColor,
                                        text: "This transaction has been fully settled",
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. HERO BALANCE CARD
// ─────────────────────────────────────────────────────────────────────────────
class _HeroBalanceCard extends StatelessWidget {
  final Trx transaction;
  final LoanCalculator loanCalc;
  final bool isPaid;
  final bool isCompound;
  final Payment? settlement;
  final String currencySymbol;
  final ValueChanged<bool>? onToggleCompound;
  final VoidCallback onCopyId;
  final VoidCallback onShare;

  const _HeroBalanceCard({
    required this.transaction,
    required this.loanCalc,
    required this.isPaid,
    this.isCompound = false,
    required this.settlement,
    required this.currencySymbol,
    this.onToggleCompound,
    required this.onCopyId,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final double calculatedAmount = isCompound
        ? loanCalc.compoundTotalAmount
        : loanCalc.totalAmount;
    final double displayAmount =
        isPaid && settlement != null ? settlement!.amountpaid : calculatedAmount;

    final double principal = transaction.amount;
    final double total = displayAmount;
    final double interest = (total - principal).clamp(0.0, double.infinity);
    final double principalRatio =
        total > 0 ? (principal / total).clamp(0.0, 1.0) : 1.0;
    final double interestRatio =
        total > 0 ? (interest / total).clamp(0.0, 1.0) : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPaid
              ? const [Color(0xFF0F766E), Color(0xFF047857)]
              : isCompound
                  ? const [Color(0xFF4338CA), Color(0xFF6D28D9)]
                  : const [Color(0xFF0284C7), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: (isPaid
                    ? const Color(0xFF0F766E)
                    : isCompound
                        ? const Color(0xFF4338CA)
                        : const Color(0xFF0284C7))
                .withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Status badge, Compound switch & Trx ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPaid
                            ? Icons.check_circle_rounded
                            : Icons.access_time_filled_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      BodySmallText(
                        bold: true,
                        color: Colors.white,
                        text: isPaid ? "SETTLED" : "ACTIVE LOAN",
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (!isPaid && onToggleCompound != null)
                      InkWell(
                        onTap: () => onToggleCompound!(!isCompound),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: isCompound ? 0.3 : 0.2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isCompound
                                    ? Icons.auto_graph_rounded
                                    : Icons.linear_scale_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              BodySmallText(
                                bold: true,
                                color: Colors.white,
                                text: isCompound ? "COMPOUND" : "SIMPLE",
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: onCopyId,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            BodySmallText(
                              bold: true,
                              color: Colors.white.withValues(alpha: 0.9),
                              text: "#${transaction.id}",
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.copy_rounded,
                              size: 13,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: BodySmallText(
                    key: ValueKey<String>(
                      isPaid
                          ? "paid"
                          : isCompound
                              ? "compound"
                              : "simple",
                    ),
                    bold: true,
                    color: Colors.white.withValues(alpha: 0.8),
                    text: isPaid
                        ? "TOTAL PAID AMOUNT"
                        : isCompound
                            ? "TOTAL OUTSTANDING (COMPOUND)"
                            : "TOTAL OUTSTANDING (SIMPLE)",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: TitleWidget(
                key: ValueKey<double>(displayAmount),
                bold: true,
                color: Colors.white,
                text: "$currencySymbol ${Utility.doubleFormate(displayAmount)}",
              ),
            ),

            const SizedBox(height: 14),

            // Visual Proportion Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 7,
                child: Row(
                  children: [
                    Expanded(
                      flex: (principalRatio * 100).round().clamp(1, 100),
                      child: Container(color: const Color(0xFF38BDF8)),
                    ),
                    Expanded(
                      flex: (interestRatio * 100).round().clamp(1, 100),
                      child: Container(color: const Color(0xFFFBBF24)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Breakdown labels
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF38BDF8),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: BodySmallText(
                          bold: true,
                          color: Colors.white.withValues(alpha: 0.9),
                          text:
                              "Principal: $currencySymbol ${Utility.doubleFormate(principal)}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFBBF24),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: BodySmallText(
                          bold: true,
                          color: Colors.white.withValues(alpha: 0.9),
                          text:
                              "Interest: $currencySymbol ${Utility.doubleFormate(interest)}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. CUSTOMER SUMMARY CARD
// ─────────────────────────────────────────────────────────────────────────────
class _CustomerSummaryCard extends ConsumerWidget {
  final int customerId;
  final bool isDark;
  final Color cardBg;
  final Color borderColor;

  const _CustomerSummaryCard({
    required this.customerId,
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
  });

  void _openProof(BuildContext context, WidgetRef ref) {
    final String? proofFullPath = ref.read(customerProofPathProvider(customerId));
    if (proofFullPath != null) {
      Routes.navigateToImageView(
        context: context,
        imagePath: proofFullPath,
        titile: "Customer ID Proof",
      );
    } else {
      SnackBarWidget.snackBarWidget(
        context: context,
        message: "Customer proof document not found",
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Customer?> customerAsync =
        ref.watch(customerProvider(customerId));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Routes.navigateToContactDetailsView(
          context,
          customerID: customerId,
        ),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: customerAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
            error: (_, _) => const BodyTwoDefaultText(
              error: true,
              text: "Error loading customer",
            ),
            data: (Customer? customer) {
              if (customer == null) {
                return const BodyTwoDefaultText(
                  text: "Customer details not found",
                );
              }

              final bool hasProof = customer.proof.trim().isNotEmpty;

              return Column(
                children: [
                  Row(
                    children: [
                      CircularImageWidget(
                        customeSize: 48,
                        imageData: customer.photo,
                        titile: customer.name,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BodyTwoDefaultText(
                              bold: true,
                              text: customer.name,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.getPrimaryTextColor,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            BodySmallText(
                              text: "${customer.guardianName} • ${customer.address}",
                              color: AppColors.getLigthGreyColor,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            BodySmallText(
                              bold: true,
                              text: customer.number,
                              color: AppColors.getPrimaryColor,
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: "Call Customer",
                        onPressed: () => Utility.makeCall(phoneNumber: customer.number),
                        icon: const Icon(Icons.call_rounded, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.getPrimaryColor.withValues(
                            alpha: isDark ? 0.2 : 0.1,
                          ),
                          foregroundColor: AppColors.getPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  if (hasProof) ...[
                    const SizedBox(height: 12),
                    Divider(height: 1, color: borderColor),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.badge_outlined,
                              size: 16,
                              color: AppColors.getLigthGreyColor,
                            ),
                            SizedBox(width: 6),
                            BodySmallText(
                              text: "Customer ID Proof",
                              color: AppColors.getLigthGreyColor,
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => _openProof(context, ref),
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Row(
                              children: [
                                BodySmallText(
                                  bold: true,
                                  color: AppColors.getPrimaryColor,
                                  text: "View Document",
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 16,
                                  color: AppColors.getPrimaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. METRICS GRID (4 Clean Detail Cards)
// ─────────────────────────────────────────────────────────────────────────────
class _MetricsGrid extends StatelessWidget {
  final LoanCalculator loanCalc;
  final Trx transaction;
  final String currencySymbol;
  final bool isCompound;
  final bool isDark;
  final Color cardBg;
  final Color borderColor;

  const _MetricsGrid({
    required this.loanCalc,
    required this.transaction,
    required this.currencySymbol,
    this.isCompound = false,
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final double interestValue = isCompound
        ? loanCalc.compoundInterestAmount
        : loanCalc.totalInterestAmount;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.account_balance_wallet_rounded,
                title: "Principal Loan",
                value: "$currencySymbol ${Utility.doubleFormate(transaction.amount)}",
                subtitle: "Initial amount taken",
                isDark: isDark,
                cardBg: cardBg,
                borderColor: borderColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                icon: Icons.percent_rounded,
                title: "Interest Rate",
                value: "${transaction.intrestRate.toStringAsFixed(1)}% / mo",
                subtitle: "Annual: ${(transaction.intrestRate * 12).toStringAsFixed(1)}% p.a.",
                isDark: isDark,
                cardBg: cardBg,
                borderColor: borderColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.calendar_month_rounded,
                title: "Duration Count",
                value: loanCalc.monthsAndRemainingDays,
                subtitle: "${loanCalc.days} Total Counted Days",
                isDark: isDark,
                cardBg: cardBg,
                borderColor: borderColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                icon: isCompound
                    ? Icons.auto_graph_rounded
                    : Icons.trending_up_rounded,
                title: isCompound ? "Compound Interest" : "Total Interest",
                value: "$currencySymbol ${Utility.doubleFormate(interestValue)}",
                subtitle: isCompound
                    ? "Compounded balance"
                    : "$currencySymbol ${Utility.doubleFormate(loanCalc.interestPerMonth)} / mo",
                isDark: isDark,
                cardBg: cardBg,
                borderColor: borderColor,
                accentColor: isCompound ? const Color(0xFF8B5CF6) : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final Color? accentColor;

  const _MetricTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = accentColor ?? AppColors.getPrimaryColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: iconColor.withValues(
                  alpha: isDark ? 0.16 : 0.1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(height: 10),
            BodySmallText(
              bold: true,
              text: title,
              color: AppColors.getLigthGreyColor,
            ),
            const SizedBox(height: 2),
            BodyTwoDefaultText(
              bold: true,
              text: value,
              color: isDark ? Colors.white : AppColors.getPrimaryTextColor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            BodySmallText(
              text: subtitle,
              color: AppColors.getLigthGreyColor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. FINANCIAL BREAKDOWN CARD
// ─────────────────────────────────────────────────────────────────────────────
class _BreakdownCard extends StatelessWidget {
  final LoanCalculator loanCalc;
  final Trx transaction;
  final Payment? settlement;
  final bool isPaid;
  final bool isCompound;
  final String currencySymbol;
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final ValueChanged<bool>? onToggleCompound;

  const _BreakdownCard({
    required this.loanCalc,
    required this.transaction,
    required this.settlement,
    required this.isPaid,
    this.isCompound = false,
    required this.currencySymbol,
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
    this.onToggleCompound,
  });

  String _formatDateString(DateTime date) {
    final DateFormat readable = DateFormat('dd MMM yyyy');
    final String standard = Utility.formatDate(date: date);
    return "${readable.format(date)} ($standard)";
  }

  @override
  Widget build(BuildContext context) {
    final String startDate = _formatDateString(transaction.transacrtionDate);
    final String endDate = isPaid && settlement != null
        ? _formatDateString(settlement!.paymentDate)
        : _formatDateString(DateTime.now());

    final double effectivePayable = isCompound
        ? loanCalc.compoundTotalAmount
        : loanCalc.totalAmount;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  size: 18,
                  color: AppColors.getPrimaryColor,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: BodyTwoDefaultText(
                    bold: true,
                    text: "Financial Ledger Breakdown",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isPaid && onToggleCompound != null) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => onToggleCompound!(!isCompound),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: (isCompound ? const Color(0xFF6D28D9) : AppColors.getPrimaryColor)
                            .withValues(alpha: isDark ? 0.25 : 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (isCompound ? const Color(0xFF6D28D9) : AppColors.getPrimaryColor)
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCompound
                                ? Icons.auto_graph_rounded
                                : Icons.linear_scale_rounded,
                            size: 12,
                            color: isCompound ? const Color(0xFF8B5CF6) : AppColors.getPrimaryColor,
                          ),
                          const SizedBox(width: 4),
                          BodySmallText(
                            bold: true,
                            color: isCompound ? const Color(0xFF8B5CF6) : AppColors.getPrimaryColor,
                            text: isCompound ? "Compound" : "Simple",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: borderColor),
            const SizedBox(height: 10),

            _buildRow(
              "Loan Issue Date",
              startDate,
              isDark: isDark,
            ),
            _buildRow(
              isPaid ? "Settlement Date" : "Calculation Date",
              endDate,
              isDark: isDark,
            ),
            _buildRow(
              "Duration Interval",
              "${loanCalc.monthsAndRemainingDays} (${loanCalc.days} days)",
              isDark: isDark,
            ),
            _buildRow(
              "Base Principal",
              "$currencySymbol ${Utility.doubleFormate(transaction.amount)}",
              isDark: isDark,
            ),
            _buildRow(
              "Rate of Interest",
              "${transaction.intrestRate.toStringAsFixed(1)}% per month",
              isDark: isDark,
            ),
            _buildRow(
              isCompound ? "Compound Total Interest" : "Simple Total Interest",
              "$currencySymbol ${Utility.doubleFormate(isCompound ? loanCalc.compoundInterestAmount : loanCalc.totalInterestAmount)}",
              isDark: isDark,
              highlightColor: const Color(0xFFD97706),
            ),

            const SizedBox(height: 10),

            // Compound Interest Insight Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A).withValues(alpha: 0.6)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_graph_rounded,
                        size: 15,
                        color: AppColors.getPrimaryColor,
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: BodySmallText(
                          bold: true,
                          text: "Compound Interest Comparison",
                          color: AppColors.getPrimaryColor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isPaid && onToggleCompound != null) ...[
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => onToggleCompound!(!isCompound),
                          child: BodySmallText(
                            bold: true,
                            color: AppColors.getPrimaryColor,
                            text: isCompound ? "Use Simple" : "Apply Compound",
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Expanded(
                        child: BodySmallText(
                          text: "Compound Interest",
                          color: AppColors.getLigthGreyColor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      BodySmallText(
                        bold: true,
                        text:
                            "$currencySymbol ${Utility.doubleFormate(loanCalc.compoundInterestAmount)}",
                        color: const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Expanded(
                        child: BodySmallText(
                          text: "Compound Total Amount",
                          color: AppColors.getLigthGreyColor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      BodySmallText(
                        bold: true,
                        text:
                            "$currencySymbol ${Utility.doubleFormate(loanCalc.compoundTotalAmount)}",
                        color: isDark ? Colors.white : AppColors.getPrimaryTextColor,
                      ),
                    ],
                  ),
                  if (loanCalc.compoundInterestAmount > loanCalc.totalInterestAmount) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Expanded(
                          child: BodySmallText(
                            text: "Difference (Comp. - Simple)",
                            color: AppColors.getLigthGreyColor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        BodySmallText(
                          bold: true,
                          text:
                              "+$currencySymbol ${Utility.doubleFormate(loanCalc.compoundInterestAmount - loanCalc.totalInterestAmount)}",
                          color: const Color(0xFF10B981),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 6),
            Divider(height: 1, color: borderColor),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: BodyTwoDefaultText(
                    bold: true,
                    text: isPaid
                        ? "Total Paid (Settled)"
                        : isCompound
                            ? "Total Payable (Compound)"
                            : "Total Payable (Simple)",
                    color: isDark ? Colors.white : AppColors.getPrimaryTextColor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                BodyTwoDefaultText(
                  bold: true,
                  color: isCompound ? const Color(0xFF8B5CF6) : AppColors.getPrimaryColor,
                  text:
                      "$currencySymbol ${Utility.doubleFormate(isPaid && settlement != null ? settlement!.amountpaid : effectivePayable)}",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    required bool isDark,
    Color? highlightColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: BodySmallText(
              text: label,
              color: AppColors.getLigthGreyColor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          BodySmallText(
            bold: true,
            text: value,
            color: highlightColor ??
                (isDark ? Colors.white : AppColors.getPrimaryTextColor),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. TIMELINE / SETTLEMENT STATUS CARD
// ─────────────────────────────────────────────────────────────────────────────
class _TimelineCard extends StatelessWidget {
  final Trx transaction;
  final Payment? settlement;
  final bool isPaid;
  final String currencySymbol;
  final bool isDark;
  final Color cardBg;
  final Color borderColor;

  const _TimelineCard({
    required this.transaction,
    required this.settlement,
    required this.isPaid,
    required this.currencySymbol,
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd MMM yyyy');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.history_toggle_off_rounded,
                  size: 18,
                  color: AppColors.getPrimaryColor,
                ),
                SizedBox(width: 8),
                BodyTwoDefaultText(
                  bold: true,
                  text: "Transaction Lifecycle",
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Step 1: Loan Disbursed
            _buildTimelineStep(
              icon: Icons.arrow_outward_rounded,
              iconColor: const Color(0xFF0284C7),
              title: "Loan Given / Disbursed",
              subtitle:
                  "${formatter.format(transaction.transacrtionDate)} (${Utility.formatDate(date: transaction.transacrtionDate)}) • $currencySymbol ${Utility.doubleFormate(transaction.amount)}",
              isCompleted: true,
              isLast: !isPaid,
              isDark: isDark,
            ),

            // Step 2: Settled or Ongoing
            if (isPaid && settlement != null)
              _buildTimelineStep(
                icon: Icons.check_circle_rounded,
                iconColor: AppColors.getGreenColor,
                title: "Loan Fully Settled (${settlement!.type.toUpperCase()})",
                subtitle:
                    "${formatter.format(settlement!.paymentDate)} (${Utility.formatDate(date: settlement!.paymentDate)}) • Total $currencySymbol ${Utility.doubleFormate(settlement!.amountpaid)}",
                isCompleted: true,
                isLast: true,
                isDark: isDark,
              )
            else
              _buildTimelineStep(
                icon: Icons.pending_actions_rounded,
                iconColor: const Color(0xFFD97706),
                title: "Currently Active & Accruing Interest",
                subtitle: "Awaiting final settlement payment",
                isCompleted: false,
                isLast: true,
                isDark: isDark,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isLast,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: iconColor.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyTwoDefaultText(
                  bold: true,
                  text: title,
                  color: isDark ? Colors.white : AppColors.getPrimaryTextColor,
                ),
                const SizedBox(height: 2),
                BodySmallText(
                  text: subtitle,
                  color: AppColors.getLigthGreyColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. SECURITY & DOCUMENTATION CARD (Pawned Item & Signature)
// ─────────────────────────────────────────────────────────────────────────────
class _DocumentationCard extends ConsumerWidget {
  final Trx transaction;
  final bool isDark;
  final Color cardBg;
  final Color borderColor;

  const _DocumentationCard({
    required this.transaction,
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Items?> itemAsync =
        ref.watch(itemByIdProvider(transaction.itemId));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.security_rounded,
                  size: 18,
                  color: AppColors.getPrimaryColor,
                ),
                SizedBox(width: 8),
                BodyTwoDefaultText(
                  bold: true,
                  text: "Collateral Item & Digital Signature",
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: borderColor),
            const SizedBox(height: 12),

            // Pawned Collateral Item
            itemAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator.adaptive(),
                ),
              ),
              error: (_, _) => const BodyTwoDefaultText(
                error: true,
                text: "Error loading collateral item",
              ),
              data: (Items? item) {
                if (item == null) {
                  return const BodyTwoDefaultText(
                    text: "No collateral item recorded",
                  );
                }

                return Row(
                  children: [
                    if (item.photo.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ImageWidget(
                          title: item.description.isNotEmpty
                              ? item.description
                              : "Collateral Item",
                          height: 54,
                          width: 54,
                          imagePath: item.photo,
                          errorBuilder: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppColors.getPrimaryColor.withValues(
                                alpha: isDark ? 0.2 : 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.getPrimaryColor,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.getPrimaryColor.withValues(
                            alpha: isDark ? 0.2 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.getPrimaryColor,
                        ),
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BodySmallText(
                            bold: true,
                            text: "Collateral / Pawned Item",
                            color: AppColors.getLigthGreyColor,
                          ),
                          const SizedBox(height: 2),
                          BodyTwoDefaultText(
                            bold: true,
                            text: item.description.isNotEmpty
                                ? item.description
                                : "No description provided",
                            color: isDark
                                ? Colors.white
                                : AppColors.getPrimaryTextColor,
                          ),
                          if (item.photo.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            const BodySmallText(
                              text: "Tap image to preview",
                              color: AppColors.getPrimaryColor,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            if (transaction.signature.isNotEmpty) ...[
              const SizedBox(height: 14),
              Divider(height: 1, color: borderColor),
              const SizedBox(height: 14),

              // Borrower Signature
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodySmallText(
                          bold: true,
                          text: "Borrower Digital Signature",
                          color: AppColors.getLigthGreyColor,
                        ),
                        SizedBox(height: 4),
                        BodySmallText(
                          text: "Verified & agreed to terms\nTap to view full signature",
                          color: AppColors.getLigthGreyColor,
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: ImageWidget(
                        title: "Borrower Signature",
                        imagePath: transaction.signature,
                        height: 48,
                        width: 96,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
