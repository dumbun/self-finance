import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history_model.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/status_chip_widget.dart';

class HistoryDetailedView extends ConsumerWidget {
  const HistoryDetailedView({super.key, required this.history});

  final UserHistory history;

  String _formatDate(DateTime date) {
    return "${DateFormat.yMMMMEEEEd().format(date)} ${DateFormat.Hm().format(date)}";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String formattedDate = _formatDate(history.eventDate);
    final bool isDebit = history.eventType == Constant.debited;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref
            .read(transactionByIDProvider(history.transactionID).notifier)
            .shareTransaction(),
        child: const Icon(Icons.share_rounded),
      ),
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: BodyTwoDefaultText(
          bold: true,
          text: 'History ID: ${history.id!.toString()}',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderSection(
                history: history,
                formattedDate: formattedDate,
                isDebit: isDebit,
              ),
              SizedBox(height: 20.sp),
              _TransactionSection(transactionId: history.transactionID),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.history,
    required this.formattedDate,
    required this.isDebit,
  });

  final UserHistory history;
  final String formattedDate;
  final bool isDebit;

  void _navigateToContact(BuildContext context) {
    Routes.navigateToContactDetailsView(
      context,
      customerID: history.customerID,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color amountColor = isDebit
        ? AppColors.getErrorColor
        : AppColors.getGreenColor;
    final String formattedAmount =
        '${isDebit ? '-' : '+'} ${Utility.doubleFormate(history.amount)}';
    final namePrefix = isDebit ? 'To' : 'From';

    return Container(
      margin: EdgeInsets.only(top: 18.sp),
      padding: EdgeInsets.symmetric(horizontal: 18.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CurrencyWidget(
                  titleText: true,
                  color: amountColor,
                  amount: formattedAmount,
                ),
                GestureDetector(
                  onTap: () => _navigateToContact(context),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 60.sp),
                    child: Consumer(
                      builder:
                          (BuildContext context, WidgetRef ref, Widget? child) {
                            return ref
                                .watch(customerProvider(history.customerID))
                                .when(
                                  data: (Customer? customer) {
                                    if (customer == null) {
                                      return const BodyTwoDefaultText(
                                        text: Constant
                                            .errorFetchingContactMessage,
                                      );
                                    }
                                    return BodyOneDefaultText(
                                      overflow: TextOverflow.ellipsis,
                                      bold: true,
                                      color: AppColors.getPrimaryColor,
                                      text: '$namePrefix ${customer.name}',
                                    );
                                  },
                                  error: (error, stackTrace) =>
                                      const BodyTwoDefaultText(
                                        text: Constant
                                            .errorFetchingContactMessage,
                                      ),
                                  loading: () => const Center(
                                    child: LinearProgressIndicator(),
                                  ),
                                );
                          },
                    ),
                  ),
                ),
                BodyTwoDefaultText(text: formattedDate),
              ],
            ),
          ),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              return ref
                  .watch(customerProvider(history.customerID))
                  .when(
                    data: (Customer? customer) {
                      if (customer == null) return const DefaultUserImage();
                      return CircularImageWidget(
                        imageData: customer.photo,
                        titile: customer.name,
                      );
                    },
                    error: (error, stackTrace) => const BodyTwoDefaultText(
                      text: Constant.errorFetchingContactMessage,
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }
}

class _TransactionSection extends ConsumerWidget {
  const _TransactionSection({required this.transactionId});

  final int transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(transactionByIDProvider(transactionId))
        .when(
          data: (Trx? trx) {
            if (trx == null) {
              return const Center(
                child: BodyTwoDefaultText(text: 'No transaction found'),
              );
            }

            return Column(
              children: [
                _TransactionInfoCard(
                  title: Constant.rateOfIntrest,
                  value: trx.intrestRate.toString(),
                ),
                _TransactionStatusCard(transactionType: trx.transacrtionType),
                SizedBox(height: 24.sp),
                Center(
                  child: TextButton(
                    onPressed: () => Routes.navigateToTransactionDetailsView(
                      context: context,
                      transacrtionId: trx.id!,
                      customerId: trx.customerId,
                    ),
                    child: const BodyOneDefaultText(
                      text: Constant.showTransaction,
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
          error: (e, _) =>
              Center(child: BodyTwoDefaultText(text: 'Error: ${e.toString()}')),
        );
  }
}

// Separate widget to prevent unnecessary rebuilds
class _TransactionInfoCard extends StatelessWidget {
  const _TransactionInfoCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: BodyTwoDefaultText(text: title),
        trailing: BodyTwoDefaultText(bold: true, text: value),
      ),
    );
  }
}

// Separate widget to prevent unnecessary rebuilds
class _TransactionStatusCard extends StatelessWidget {
  const _TransactionStatusCard({required this.transactionType});

  final String transactionType;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const BodyTwoDefaultText(text: Constant.transacrtionStatus),
        trailing: StatusChipWidget(transactionType),
      ),
    );
  }
}
