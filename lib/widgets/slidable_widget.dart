import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
    return Slidable(
      key: UniqueKey(),
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: <SlidableAction>[
          SlidableAction(
            onPressed: (BuildContext context) async {
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
            },
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
          SlidableAction(
            onPressed: (BuildContext context) => InvoiceGenerator.shareInvoice(
              customerID: customerId,
              transactionID: transactionId,
            ),
            backgroundColor: Color(0xFF21B7CA),
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: 'Share',
          ),
        ],
      ),
      child: child,
    );
  }
}
