import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/core/theme/app_colors.dart';

enum TransactionsFilters {
  oneMonth(1),
  threeMonths(3),
  sixMonths(6), // Fixed typo: sixMoths -> sixMonths
  moreThanAYear(12); // Fixed typo: moreThanAYera -> moreThanAYear

  final int value;

  const TransactionsFilters(this.value);

  String get label {
    switch (this) {
      case TransactionsFilters.oneMonth:
        return '1 Month +';
      case TransactionsFilters.threeMonths:
        return '3 Months +';
      case TransactionsFilters.sixMonths:
        return '6 Months +';
      case TransactionsFilters.moreThanAYear:
        return '12 Months +';
    }
  }

  int get months {
    return value; // Simplified - just return the value directly!
  }
}

class TransactionFilterWidget extends ConsumerWidget {
  const TransactionFilterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: TransactionsFilters.values.map((TransactionsFilters filter) {
          return Padding(
            padding: EdgeInsetsGeometry.only(right: 12.sp),
            child: FilterChip(
              checkmarkColor: AppColors.getPrimaryColor,
              selected: filters.contains(filter),
              label: BodyTwoDefaultText(text: filter.label),
              onSelected: (bool selected) =>
                  ref.read(filterProvider.notifier).setFilter(filter, selected),
            ),
          );
        }).toList(),
      ),
    );
  }
}
