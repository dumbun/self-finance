import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/invoice_generator_utility.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';

class SlidableWidget extends ConsumerWidget {
  const SlidableWidget({
    super.key,
    required this.transactionId,
    required this.customerId,
    required this.child,
  });
  final int transactionId;
  final int customerId;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> delete() async {
      final int a = await AlertDilogs.alertDialogWithTwoAction(
        context,
        "Are you sure ?",
        "Do you really want to delete this contact.\n\nDeleting this transaction can erease it's history and payments and item details too",
      );
      if (a == 1) {
        await ref
            .read(asyncTransactionsProvider.notifier)
            .deleteTransactionAndHistory(transactionId);
      }
    }

    return Slidable(
      closeOnScroll: true,
      key: UniqueKey(),
      endActionPane: ActionPane(
        dismissible: DismissiblePane(onDismissed: () async => await delete()),
        motion: StretchMotion(),
        children: [
          CustomSlidableAction(
            onPressed: (BuildContext context) => InvoiceGenerator.shareInvoice(
              customerID: customerId,
              transactionID: transactionId,
            ),
            backgroundColor: AppColors.contentColorCyan,
            foregroundColor: Colors.white,
            child: Icon(Icons.share_rounded, size: 22.sp),
          ),
          CustomSlidableAction(
            foregroundColor: Colors.white,
            onPressed: (BuildContext context) async => delete(),
            backgroundColor: AppColors.getErrorColor,
            child: Icon(Icons.delete_forever_rounded, size: 22.sp),
          ),
        ],
      ),

      child: child,
    );
  }
}
