import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/views/history/history_providers.dart';
import 'package:self_finance/widgets/title_widget.dart';

class HistoryView extends ConsumerWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String hintText = ref.watch(hintTextProvider);
    final String filterText = ref.watch(selectedFilterProvider);

    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16.sp),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(ref),
            SizedBox(height: 10.sp),
            _buildSearchBar(ref, hintText, filterText),
          ],
        ),
      ),
    );
  }

  SearchBar _buildSearchBar(WidgetRef ref, String hintText, filterText) {
    return SearchBar(
      elevation: const MaterialStatePropertyAll(0),
      padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.only(left: 16.sp)),
      hintText: hintText,
      leading: const Icon(Icons.search),
      trailing: [
        //! use drop down menu
        //todo change the filters
        PopupMenuButton<String>(
          onSelected: (String filter) {
            ref.read(selectedFilterProvider.notifier).update((state) => state = filter);
          },
          initialValue: filterText,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: mobileNumber,
              child: Text(mobileNumber),
            ),
            const PopupMenuItem<String>(
              value: customerName,
              child: Text(customerName),
            ),
            const PopupMenuItem<String>(
              value: customerPlace,
              child: Text(customerPlace),
            ),
          ],
        ),
      ],
      onChanged: (value) {
        //todo  search the user given input to the search bar
        // using filter text we can search the data user requried
        print(filterText);
      },
    );
  }

  TitleWidget _buildTitle(WidgetRef ref) {
    return const TitleWidget(text: history);
  }
}
