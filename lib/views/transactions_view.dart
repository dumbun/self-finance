import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/widgets/build_transactions_list_widget.dart';
import 'package:self_finance/widgets/transaction_filter_widget.dart';

class TransactionsView extends HookConsumerWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController searchController = useTextEditingController();

    Future<void> refreshData() async {
      searchController.clear();
      ref.invalidate(transactionsProvider);
      ref.read(filterProvider.notifier).clear();
      ref.read(transactionsDateSearchQueryProvider.notifier).clear();
      ref.read(transactionsSearchQueryProvider.notifier).clear();
    }

    return RefreshIndicator(
      onRefresh: refreshData,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            SearchBar(
              controller: searchController,
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 12),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              elevation: const WidgetStatePropertyAll(0),
              hintText: "Search transaction ID",
              hintStyle: const WidgetStatePropertyAll(
                TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              leading: const Icon(Icons.search),
              onChanged: (String value) {
                ref.read(transactionsSearchQueryProvider.notifier).set(value);
              },
              trailing: <Widget>[
                IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      currentDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      keyboardType: TextInputType.text,
                      switchToCalendarEntryModeIcon: const Icon(
                        Icons.calendar_month,
                      ),
                    );

                    if (pickedDate == null) return;

                    searchController.text = DateFormat(
                      'dd-MM-yyyy',
                    ).format(pickedDate);

                    ref
                        .read(transactionsDateSearchQueryProvider.notifier)
                        .set(pickedDate);
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            const TransactionFilterWidget(),

            const SizedBox(height: 16),

            const Expanded(child: BuildTransactionsListWidget()),
          ],
        ),
      ),
    );
  }
}
