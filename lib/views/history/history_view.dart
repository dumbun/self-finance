import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/views/history/history_providers.dart';
import 'package:self_finance/widgets/detail_card_widget.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/title_widget.dart';

class HistoryView extends ConsumerWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String hintText = ref.watch(hintTextProvider);
    final String filterText = ref.watch(selectedFilterProvider);
    Future<List<Transactions>> dataFuture = BackEnd.fetchLatestTransactions();

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
            SizedBox(height: 10.sp),
            _buildData(dataFuture),
          ],
        ),
      ),
    );
  }

  FutureBuilder<List<Transactions>> _buildData(dataFuture) {
    return FutureBuilder<List<Transactions>>(
      future: dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive()); // Placeholder for loading state
        } else if (snapshot.hasError) {
          // return Text(snapshot.error.toString());
          return AlertDilogs.alertDialogWithOneAction(context, error, 'Error fetching data: ${snapshot.error}');
        } else {
          // Check if data is null or empty
          final List<Transactions>? data = snapshot.data;
          if (data == null || data.isEmpty) {
            return const Center(
              child: Text(noTransactionsFound),
            );
          }

          if (data.isEmpty || data == []) {
            return const Center(
              child: Text(noTransactionsFound),
            );
          }

          return Expanded(
            child: ListView.builder(
              key: ValueKey(data),
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                return DetailCardWidget(data: data[index]);
              },
            ),
          );
        }
      },
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
            switch (filter) {
              case mobileNumber:
                ref.read(hintTextProvider.notifier).update((state) => searchMobile);
                break;
              case customerName:
                ref.read(hintTextProvider.notifier).update((state) => searchName);
                break;
              case customerPlace:
                ref.read(hintTextProvider.notifier).update((state) => searchPlace);
                break;
              default:
                ref.read(hintTextProvider.notifier).update((state) => searchMobile);
            }
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
      onChanged: (String value) {
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
