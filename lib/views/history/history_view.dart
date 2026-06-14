import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:self_finance/providers/history_provider.dart';
import 'package:self_finance/widgets/build_history_list_widget.dart';

class HistoryView extends HookConsumerWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SearchController searchController = useSearchController();

    return RefreshIndicator(
      onRefresh: () async {
        searchController.clear();
        ref.invalidate(historyProvider);
      },
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
              hintText: 'phone number or customer name',
              hintStyle: const WidgetStatePropertyAll(
                TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              leading: const Icon(Icons.person_search_sharp),
              onChanged: (value) {
                ref.read(historyProvider.notifier).doSearch(userInput: value);
              },
            ),
            const SizedBox(height: 12),
            const Expanded(child: BuildHistoryListWidget()),
          ],
        ),
      ),
    );
  }
}
