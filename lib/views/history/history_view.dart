import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/providers.dart';
import 'package:self_finance/views/history/history_providers.dart';
import 'package:self_finance/widgets/detail_card_widget.dart';
import 'package:self_finance/widgets/title_widget.dart';

class HistoryView extends ConsumerStatefulWidget {
  const HistoryView({super.key});

  @override
  ConsumerState<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends ConsumerState<HistoryView> {
  void fetchData() async {
    List<Transactions> l = [];
    //converts the async values into a sync values
    l = await BackEnd.fetchLatestTransactions();
    ref.read(listOfTransactionsProvider.notifier).state = l;
  }

  @override
  void initState() {
    // fetches and changes the state of the provider when the screen first loades
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String hintText = ref.watch(hintTextProvider);
    final String filterText = ref.watch(selectedFilterProvider);
    final List<Transactions> data = ref.watch(listOfTransactionsProvider);

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
            _buildSearchBar(ref, hintText, filterText, data),
            SizedBox(height: 10.sp),
            _buildData(data),

            // _buildData(dataFuture),
          ],
        ),
      ),
    );
  }

  Expanded _buildData(List<Transactions> data) {
    return Expanded(
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          if (data.isEmpty) {
            return const Center(
              child: Text(noTransactionsFound),
            );
          }
          if (data == []) {
            return const Center(
              child: Text(noTransactionsFound),
            );
          }
          return DetailCardWidget(data: data[index]);
        },
      ),
    );
  }

  SearchBar _buildSearchBar(WidgetRef ref, String hintText, filterText, data) {
    return SearchBar(
      elevation: const MaterialStatePropertyAll(0),
      padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.only(left: 16.sp)),
      hintText: hintText,
      leading: const Icon(Icons.search),
      trailing: [
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
        if (value == "") {
          _doReset();
        }
        if (filterText == mobileNumber) {
          // data manupulate when user searches with mobile number filter
          _doMobileSearch(value);
          if (value == "") {
            _doReset();
          }
        } else if (filterText == customerName) {
          // data manupulate when user searches with Customer name filter
          _doNameSearch(value);
          if (value == "") {
            _doReset();
          }
        } else if (filterText == customerPlace) {
          // data manupulate when user searches with Customer place filter
          _doPlaceSearch(value);
          if (value == "") {
            _doReset();
          }
        }
      },
    );
  }

  _doReset() async {
    ref.read(listOfTransactionsProvider.notifier).state = await BackEnd.fetchLatestTransactions();
  }

  _doMobileSearch(String mobileNumber) async {
    List<Transactions> showdowData = await BackEnd.fetchLatestTransactions();
    var result = showdowData.where((element) {
      if (element.mobileNumber.contains(mobileNumber)) {
        return element.mobileNumber.contains(mobileNumber);
      } else {
        // _doReset();
        return false;
      }
    }).toList();
    ref.read(listOfTransactionsProvider.notifier).state = result;
  }

  _doNameSearch(String name) async {
    List<Transactions> showdowData = await BackEnd.fetchLatestTransactions();
    var result = showdowData.where((element) {
      if (element.customerName.contains(name)) {
        return element.customerName.contains(name);
      } else {
        // _doReset();
        return false;
      }
    }).toList();
    ref.read(listOfTransactionsProvider.notifier).state = result;
  }

  _doPlaceSearch(String place) async {
    List<Transactions> showdowData = await BackEnd.fetchLatestTransactions();
    var result = showdowData.where((element) {
      if (element.address.contains(place)) {
        return element.address.contains(place);
      } else {
        // _doReset();
        return false;
      }
    }).toList();
    ref.read(listOfTransactionsProvider.notifier).state = result;
  }

  TitleWidget _buildTitle(WidgetRef ref) {
    return const TitleWidget(text: history);
  }
}
