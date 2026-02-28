import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/chart_model.dart';
import 'package:self_finance/providers/chart_tab_providers.dart';
import 'package:self_finance/widgets/currency_widget.dart';

class DrillSheet extends ConsumerWidget {
  const DrillSheet({super.key, required this.target, required this.title});
  final DrillTarget target;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<DrillItem>> dataAsync = ref.watch(
      drillDownProvider(target),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (_, ScrollController sc) => Container(
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surface, //with out this it will became transaparent
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            SizedBox(height: 16.sp),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.sp),
              child: Row(
                children: [
                  Expanded(
                    child: BodyTwoDefaultText(
                      text: 'Transactions · $title',
                      bold: true,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Divider(height: 1.sp),
            Expanded(
              child: dataAsync.when(
                data: (List<DrillItem> items) {
                  if (items.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            size: 44,
                            color: AppColors.getLigthGreyColor,
                          ),
                          SizedBox(height: 8),
                          BodyOneDefaultText(
                            text: 'No transactions for this period',
                            color: AppColors.getLigthGreyColor,
                          ),
                        ],
                      ),
                    );
                  }

                  final double totalRec = items
                      .where((e) => e.isReceived)
                      .fold(0.0, (s, e) => s + e.amount);
                  final double totalDis = items
                      .where((e) => !e.isReceived)
                      .fold(0.0, (s, e) => s + e.amount);

                  return ListView(
                    controller: sc,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    children: [
                      // Mini summary
                      Row(
                        children: [
                          _MiniStat('In', totalRec, AppColors.getPrimaryColor),
                          SizedBox(width: 12.sp),
                          _MiniStat('Out', totalDis, AppColors.getErrorColor),
                          SizedBox(width: 12.sp),
                        ],
                      ),
                      SizedBox(height: 14.sp),
                      ...items.map((item) => _DrillRow(item: item)),
                    ],
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: BodySmallText(
                      text: 'Failed to load: $e',
                      color: AppColors.getErrorColor,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BodySmallText(text: label, color: color),
            CurrencyWidget(
              amount: Utility.doubleFormate(value),
              smallText: true,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

class _DrillRow extends StatelessWidget {
  const _DrillRow({required this.item});
  final DrillItem item;

  @override
  Widget build(BuildContext context) {
    final Color color = item.isReceived
        ? AppColors.getPrimaryColor
        : AppColors.getErrorColor;
    final IconData icon = item.isReceived
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    return Container(
      margin: EdgeInsets.only(bottom: 14.sp),
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 14.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getLigthGreyColor.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            width: 24.sp,
            height: 24.sp,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          SizedBox(width: 12.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodySmallText(
                  text: item.isReceived ? 'Payment Received' : 'Loan Disbursed',
                  bold: true,
                ),
                BodySmallText(
                  text: 'ID: ${item.id}  ·  ${item.date}',
                  color: AppColors.getLigthGreyColor,
                ),
              ],
            ),
          ),
          CurrencyWidget(
            amount:
                '${item.isReceived ? '+' : '-'}\$${Utility.doubleFormate(item.amount)}',
            smallText: true,
            color: color,
          ),
        ],
      ),
    );
  }
}
