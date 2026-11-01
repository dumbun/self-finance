import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/customer/models/customer_portal_models.dart';
import 'package:self_finance/customer/widgets/customer_item_thumbnail_widget.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/status_chip_widget.dart';

class CustomerLoanDetailView extends StatelessWidget {
  final CustomerPortalLoan loan;
  final List<CustomerPortalPayment> payments;

  const CustomerLoanDetailView({
    super.key,
    required this.loan,
    required this.payments,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final DateFormat formatter = DateFormat('dd MMM yyyy');

    final loanPayments = payments
        .where((p) => p.transactionId == loan.transactionId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: BodyOneDefaultText(
          text: l10n.loanDetails,
          bold: true,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Balance Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BodyTwoDefaultText(
                            text: l10n.remainingBalance,
                            color: AppColors.getLigthGreyColor,
                          ),
                          StatusChipWidget(
                            status: loan.remainingAmount > 0
                                ? 'Active'
                                : 'Paid',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CurrencyWidget(
                        amount: Utility.doubleFormate(loan.remainingAmount),
                        titleText: true,
                        color: loan.remainingAmount > 0
                            ? AppColors.getPrimaryColor
                            : AppColors.getGreenColor,
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BodySmallText(
                                text: l10n.takenAmount,
                                color: AppColors.getLigthGreyColor,
                              ),
                              const SizedBox(height: 4),
                              CurrencyWidget(
                                amount: Utility.doubleFormate(loan.amount),
                                smallText: true,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              BodySmallText(
                                text: l10n.monthlyInterestRate,
                                color: AppColors.getLigthGreyColor,
                              ),
                              const SizedBox(height: 4),
                              BodyTwoDefaultText(
                                text: '${loan.interestRate}%',
                                bold: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Collateral Item Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 20,
                            color: AppColors.getPrimaryColor,
                          ),
                          const SizedBox(width: 8),
                          BodyOneDefaultText(
                            text: l10n.collateralItem,
                            bold: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomerItemThumbnailWidget(
                            imagePath: loan.itemPhotoPath,
                            title: loan.itemName,
                            width: 80,
                            height: 80,
                            borderRadius: 10,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BodyOneDefaultText(
                                  text: loan.itemName,
                                  bold: true,
                                ),
                                if (loan.itemDescription.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  BodySmallText(
                                    text: loan.itemDescription,
                                    color: AppColors.getLigthGreyColor,
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    BodySmallText(
                                      text: '${l10n.pawnedDate}: ',
                                      color: AppColors.getLigthGreyColor,
                                    ),
                                    BodySmallText(
                                      text: formatter.format(loan.transactionDate),
                                      bold: true,
                                    ),
                                  ],
                                ),
                                if (loan.expiryDate != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      BodySmallText(
                                        text: '${l10n.dueDate}: ',
                                        color: AppColors.getLigthGreyColor,
                                      ),
                                      BodySmallText(
                                        text: formatter.format(loan.expiryDate!),
                                        bold: true,
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Payments on this Loan
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.receipt_long_outlined,
                            size: 20,
                            color: AppColors.getPrimaryColor,
                          ),
                          const SizedBox(width: 8),
                          BodyOneDefaultText(
                            text: l10n.paymentHistory,
                            bold: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (loanPayments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: BodySmallText(
                              text: l10n.noPaymentsFound,
                              color: AppColors.getLigthGreyColor,
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: loanPayments.length,
                          separatorBuilder: (_, _) => const Divider(height: 16),
                          itemBuilder: (context, index) {
                            final p = loanPayments[index];
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    BodyTwoDefaultText(
                                      text: p.paymentType,
                                      bold: true,
                                    ),
                                    const SizedBox(height: 2),
                                    BodySmallText(
                                      text: formatter.format(p.paymentDate),
                                      color: AppColors.getLigthGreyColor,
                                    ),
                                  ],
                                ),
                                CurrencyWidget(
                                  amount: Utility.doubleFormate(p.amountPaid),
                                  color: AppColors.getGreenColor,
                                  smallText: true,
                                ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
