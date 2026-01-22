// Provider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

final filterProvider = StateProvider.autoDispose<Set<TransactionsFilters>>(
  (ref) => {},
);

class TransactionFilterWidget extends ConsumerWidget {
  const TransactionFilterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filterProvider);

    return Wrap(
      spacing: 5.0,
      children: TransactionsFilters.values.map((filter) {
        return FilterChip(
          checkmarkColor: AppColors.getPrimaryColor,
          selected: filters.contains(filter),
          label: BodyTwoDefaultText(text: filter.label),
          onSelected: (selected) => _toggleFilter(ref, filter, selected),
        );
      }).toList(),
    );
  }

  void _toggleFilter(WidgetRef ref, TransactionsFilters filter, bool selected) {
    // Toggle filter - only one at a time
    ref.read(filterProvider.notifier).state = selected ? {filter} : {};

    // Fetch based on selection
    if (selected) {
      ref
          .read(asyncTransactionsProvider.notifier)
          .fetchTransactionsByAge(filter.months);
    } else {
      ref.refresh(asyncTransactionsProvider.future).ignore();
    }
  }
}
