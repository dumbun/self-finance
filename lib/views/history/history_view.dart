import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/providers/history_provider.dart';
import 'package:self_finance/widgets/build_history_list_widget.dart';
import 'package:self_finance/widgets/refresh_widget.dart';

class HistoryView extends ConsumerWidget {
  const HistoryView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshWidget(
      onRefresh: () => ref.refresh(asyncHistoryProvider.future),
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchBar(
              padding: WidgetStateProperty.all(
                EdgeInsets.symmetric(horizontal: 12.sp),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(20.sp),
                ),
              ),
              elevation: WidgetStatePropertyAll(0),
              hintText: "phone number or t_transactionID or customer name",
              hintStyle: WidgetStatePropertyAll(
                TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              leading: const Icon(Icons.person_search_sharp),
              onChanged: (String value) => ref
                  .read(asyncHistoryProvider.notifier)
                  .doSearch(givenInput: value),
            ),
            SizedBox(height: 12.sp),
            const Expanded(child: BuildHistoryListWidget()),
          ],
        ),
      ),
    );
  }
}
