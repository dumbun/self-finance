import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/theme/app_colors.dart';
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

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final int a = await AlertDilogs.alertDialogWithTwoAction(
      context,
      "Delete transaction?",
      "Do you really want to delete this transaction?\n\n"
          "Deleting this transaction will erase its history, payments, and item details too.",
    );

    if (a != 1) return;
    if (!context.mounted) return;

    await ref
        .read(transactionsProvider.notifier)
        .deleteTransaction(transactionId: transactionId);

    if (!context.mounted) return;
    Slidable.of(context)?.close();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double iconSize = 22.sp;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Slidable(
        key: ValueKey<int>(transactionId),
        closeOnScroll: true,
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.45,
          children: [
            _RoundedAction(
              color: AppColors.contentColorCyan,
              icon: Icons.share_rounded,
              iconSize: iconSize,
              onTap: () {
                Slidable.of(context)?.close();
                ref
                    .read(transactionByIDProvider(transactionId).notifier)
                    .shareTransaction();
              },
            ),
            _RoundedAction(
              color: AppColors.getErrorColor,
              icon: Icons.delete_forever_rounded,
              iconSize: iconSize,
              onTap: () => _confirmAndDelete(context, ref),
            ),
          ],
        ),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

class _RoundedAction extends StatelessWidget {
  const _RoundedAction({
    required this.color,
    required this.icon,
    required this.iconSize,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomSlidableAction(
      onPressed: (_) => onTap(),
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 6.sp),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: ColoredBox(
            color: color,
            child: SizedBox.expand(
              child: Center(
                child: Icon(icon, size: iconSize, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
