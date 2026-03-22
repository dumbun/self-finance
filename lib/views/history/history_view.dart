import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/providers/history_provider.dart';
import 'package:self_finance/widgets/build_history_list_widget.dart';

class HistoryView extends ConsumerStatefulWidget {
  const HistoryView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HistoryViewState();
}

class _HistoryViewState extends ConsumerState<HistoryView> {
  final SearchController _searchTextController = SearchController();
  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _searchTextController.clear();
        ref.refresh(historyProvider.future).ignore();
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchBar(
              controller: _searchTextController,
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 12),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(20),
                ),
              ),
              elevation: const WidgetStatePropertyAll(0),
              hintText: "phone number or customer name",
              hintStyle: const WidgetStatePropertyAll(
                TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              leading: const Icon(Icons.person_search_sharp),
              onChanged: (String value) =>
                  ref.read(historyProvider.notifier).doSearch(userInput: value),
            ),
            const SizedBox(height: 12),
            const Expanded(child: BuildHistoryListWidget()),
          ],
        ),
      ),
    );
  }
}
