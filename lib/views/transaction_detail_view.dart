import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/logic/logic.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/payment_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/payment_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/widgets/clipbord_widget.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/customer_card_widget.dart';
import 'package:self_finance/widgets/item_image_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:self_finance/widgets/status_chip_widget.dart';
import 'package:self_finance/widgets/image_widget.dart';
import 'package:self_finance/widgets/timeline_widget.dart';

class TransactionDetailView extends ConsumerWidget {
  const TransactionDetailView({super.key, required this.transactionId});
  final int transactionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      builder: (BuildContext context, WidgetRef ref, Widget? child) {
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

                                return SizedBox(
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      const SizedBox(height: 36),
                                      StatusChipWidget(
                                        transaction.transacrtionType,
                                      ),
                                      const SizedBox(height: 12),
                                      CurrencyWidget(
                                        titleText: true,
                                        amount: Utility.doubleFormate(
                                          l.totalAmount,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const BodyTwoDefaultText(
                                            text: "Transaction ID: ",
                                          ),
                                          BodyTwoDefaultText(
                                            text: transactionId.toString(),
                                            bold: true,
                                          ),
                                          ClipbordWidget(
                                            key: ValueKey(transactionId),
                                            value: transactionId.toString(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 36),
                                      if (payment.isNotEmpty)
                                        TimelineWidget(
                                          payment: payment.first,
                                          transaction: transaction,
                                        ),
                                      SizedBox(
                                        width: double.infinity,
                                        child: Column(
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
                                            Card(
                                              elevation: 2,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.handshake_rounded,
                                                    ),
                                                    title:
                                                        const BodyTwoDefaultText(
                                                          text: Constant
                                                              .takenAmount,
                                                        ),
                                                    trailing: CurrencyWidget(
                                                      smallText: true,
                                                      amount:
                                                          Utility.doubleFormate(
                                                            transaction.amount,
                                                          ),
                                                    ),
                                                  ),
                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.percent_rounded,
                                                    ),
                                                    title:
                                                        const BodyTwoDefaultText(
                                                          text: Constant
                                                              .rateOfIntrest,
                                                        ),
                                                    trailing:
                                                        BodyTwoDefaultText(
                                                          bold: true,
                                                          text: transaction
                                                              .intrestRate
                                                              .toString(),
                                                        ),
                                                  ),
                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.calendar_month,
                                                    ),
                                                    title:
                                                        const BodyTwoDefaultText(
                                                          text: Constant
                                                              .takenDate,
                                                        ),
                                                    trailing: BodyTwoDefaultText(
                                                      bold: true,
                                                      text: Utility.formatDate(
                                                        date: transaction
                                                            .transacrtionDate,
                                                      ),
                                                    ),
                                                  ),

                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.date_range,
                                                    ),
                                                    title: BodyTwoDefaultText(
                                                      text: payment.isEmpty
                                                          ? Constant.presentDate
                                                          : Constant
                                                                .paymentDate,
                                                    ),
                                                    trailing: BodyTwoDefaultText(
                                                      bold: true,
                                                      text: payment.isEmpty
                                                          ? Utility.formatDate(
                                                              date:
                                                                  DateTime.now(),
                                                            )
                                                          : Utility.formatDate(
                                                              date: payment
                                                                  .first
                                                                  .paymentDate,
                                                            ),
                                                    ),
                                                  ),
                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.date_range_rounded,
                                                    ),
                                                    title:
                                                        const BodyTwoDefaultText(
                                                          text:
                                                              Constant.duetime,
                                                        ),
                                                    trailing: BodyTwoDefaultText(
                                                      bold: true,
                                                      text: l
                                                          .monthsAndRemainingDays,
                                                    ),
                                                  ),
                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.auto_graph_rounded,
                                                    ),
                                                    title:
                                                        const BodyTwoDefaultText(
                                                          text: Constant
                                                              .intrestPerMonth,
                                                        ),
                                                    trailing: CurrencyWidget(
                                                      smallText: true,
                                                      amount:
                                                          Utility.doubleFormate(
                                                            l.interestPerDay *
                                                                30,
                                                          ),
                                                    ),
                                                  ),
                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.payment_rounded,
                                                    ),
                                                    title:
                                                        const BodyTwoDefaultText(
                                                          text: Constant
                                                              .totalIntrestAmount,
                                                        ),
                                                    trailing: CurrencyWidget(
                                                      smallText: true,
                                                      amount:
                                                          Utility.doubleFormate(
                                                            l.totalInterestAmount,
                                                          ),
                                                    ),
                                                  ),
                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.handshake_rounded,
                                                    ),
                                                    title:
                                                        const BodyTwoDefaultText(
                                                          text: Constant
                                                              .totalAmount,
                                                        ),
                                                    trailing: CurrencyWidget(
                                                      smallText: true,
                                                      amount:
                                                          Utility.doubleFormate(
                                                            l.totalAmount,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                                                    titile: "Signature",
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
                                      ),

                                      const SizedBox(height: 22),
                                      if (payment.isEmpty)
                                        RoundedCornerButton(
                                          text: "Mark as Paid",
                                          onPressed: () async => await ref
                                              .read(
                                                transactionByIDProvider(
                                                  transactionId,
                                                ).notifier,
                                              )
                                              .markAsPaid(
                                                amountpaid: l.totalAmount,
                                                intrestAmount:
                                                    l.totalInterestAmount,
                                              ),
                                        ),
                                      const SizedBox(height: 32),
                                    ],
                                  ),
                                );
                              },
                              error: (_, _) => const Center(
                                child: BodyTwoDefaultText(
                                  text:
                                      Constant.errorFetchingTransactionMessage,
                                ),
                              ),
                              loading: () => const Center(
                                child: CircularProgressIndicator.adaptive(),
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
                  loading: () =>
                      const Center(child: CircularProgressIndicator.adaptive()),
                ),
          ),
        ),
      ),
    );
  }
}
