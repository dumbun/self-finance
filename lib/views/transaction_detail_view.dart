import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/logic/logic.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/models/payment_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/payment_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/widgets/customer_card_widget.dart';
import 'package:self_finance/widgets/item_image_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:self_finance/widgets/image_widget.dart';
import 'package:self_finance/widgets/timeline_widget.dart';
import 'package:self_finance/widgets/transaction_details_hero_widget.dart';
import 'package:self_finance/widgets/transaction_details_widget.dart';

class TransactionDetailView extends ConsumerWidget {
  const TransactionDetailView({super.key, required this.transactionId});
  final int transactionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> markAsPaid({
      required double amountpaid,
      required double intrestAmount,
    }) async => await ref
        .read(transactionByIDProvider(transactionId).notifier)
        .markAsPaid(amountpaid: amountpaid, intrestAmount: intrestAmount);

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        actionsPadding: const EdgeInsets.only(left: 8),
        actions: [
          IconButton(
            onPressed: () => ref
                .read(transactionByIDProvider(transactionId).notifier)
                .shareTransaction(),
            icon: const Icon(
              Icons.share_rounded,
              color: AppColors.contentColorBlue,
            ),
          ),
        ],
        centerTitle: true,
        title: const BodyTwoDefaultText(
          text: 'Transaction Details',
          bold: true,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: RefreshIndicator.adaptive(
            onRefresh: () async =>
                await ref.refresh(transactionByIDProvider(transactionId)),
            child: SingleChildScrollView(
              child: ref
                  .watch(transactionByIDProvider(transactionId))
                  .when(
                    data: (Trx? transaction) {
                      if (transaction == null) {
                        return const Center(
                          child: BodyTwoDefaultText(
                            bold: true,
                            error: true,
                            text: Constant.errorFetchingTransactionMessage,
                          ),
                        );
                      }
                      return Consumer(
                        builder:
                            (
                              BuildContext context,
                              WidgetRef ref,
                              Widget? child,
                            ) {
                              return ref
                                  .watch(
                                    paymentByTrxIdProvider(
                                      transactionId: transactionId,
                                    ),
                                  )
                                  .when(
                                    data: (List<Payment> payment) {
                                      final LoanCalculator l = LoanCalculator(
                                        takenAmount: transaction.amount,
                                        rateOfInterest: transaction.intrestRate,
                                        takenDate: transaction.transacrtionDate,
                                        tenureDate: payment.isNotEmpty
                                            ? payment.first.paymentDate
                                            : null,
                                      );

                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          TransactionDetailsHeroWidget(
                                            transaction: transaction,
                                            value: l.totalAmount,
                                          ),
                                          const SizedBox(height: 36),

                                          if (payment.isNotEmpty)
                                            TimelineWidget(
                                              payment: payment.first,
                                              transaction: transaction,
                                            ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              const BodyTwoDefaultText(
                                                text: "Customer Details",
                                                bold: true,
                                              ),
                                              CustomerCardWidget(
                                                customerId:
                                                    transaction.customerId,
                                              ),
                                              const SizedBox(height: 20),
                                              const BodyTwoDefaultText(
                                                text: "Transaction Details",
                                                bold: true,
                                              ),
                                              TransactionDetailsWidget(
                                                loanCalculator: l,
                                                payment: payment,
                                                transaction: transaction,
                                              ),
                                              const SizedBox(height: 14),
                                              if (transaction
                                                  .signature
                                                  .isNotEmpty)
                                                const BodyTwoDefaultText(
                                                  text: Constant.signature,
                                                  bold: true,
                                                ),
                                              if (transaction
                                                  .signature
                                                  .isNotEmpty)
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: Card(
                                                    child: ImageWidget(
                                                      title: "Signature",
                                                      fit: BoxFit.scaleDown,
                                                      imagePath:
                                                          transaction.signature,
                                                      height: 72,
                                                      width: 72,
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(height: 14),
                                              ItemImageWidget(
                                                transactionId: transactionId,
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 22),
                                          if (payment.isEmpty)
                                            RoundedCornerButton(
                                              text: "Mark as Paid",
                                              onPressed: () async =>
                                                  await markAsPaid(
                                                    amountpaid: l.totalAmount,
                                                    intrestAmount:
                                                        l.totalInterestAmount,
                                                  ),
                                            ),
                                          const SizedBox(height: 32),
                                        ],
                                      );
                                    },
                                    error: (_, _) => const Center(
                                      child: BodyTwoDefaultText(
                                        text: Constant
                                            .errorFetchingTransactionMessage,
                                      ),
                                    ),
                                    loading: () => const Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    ),
                                  );
                            },
                      );
                    },
                    error: (_, _) => const Center(
                      child: BodyTwoDefaultText(
                        text: Constant.errorFetchingTransactionMessage,
                      ),
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
