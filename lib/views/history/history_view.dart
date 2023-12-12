import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/theme/colors.dart';
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
    //converts the async values into a sync values
    ref.read(listOfTransactionsProvider.notifier).state = await BackEnd.fetchLatestTransactions();
  }

  @override
  void initState() {
    super.initState();
    // fetches and changes the state of the provider when the screen first loades
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final String hintText = ref.watch(hintTextProvider);
    final String filterText = ref.watch(selectedFilterProvider);
    final List<Transactions> data = ref.watch(listOfTransactionsProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.read(listOfTransactionsProvider.notifier).state = await BackEnd.fetchLatestTransactions();
        },
        child: Container(
          padding: EdgeInsets.all(16.sp),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: TitleWidget(text: history),
              ),
              SizedBox(height: 20.sp),
              _buildSearchBar(ref, hintText, filterText),
              SizedBox(height: 10.sp),
              _buildData(data),
            ],
          ),
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
          return DetailCardWidget(data: data[index]);
        },
      ),
    );
  }

  SearchBar _buildSearchBar(WidgetRef ref, String hintText, filterText) {
    return SearchBar(
      elevation: const MaterialStatePropertyAll(0),
      padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.only(left: 16.sp)),
      hintText: hintText,
      leading: const Icon(
        Icons.search,
        color: AppColors.getPrimaryColor,
      ),
      trailing: [
        PopupMenuButton<String>(
          enableFeedback: true,
          icon: const Icon(Icons.filter_alt_outlined),
          iconColor: AppColors.getPrimaryColor,
          tooltip: filterText,
          onSelected: (String filter) {
            final update = ref.read(hintTextProvider.notifier);
            switch (filter) {
              case mobileNumber:
                update.update((state) => searchMobile);
                break;
              case customerName:
                update.update((state) => searchName);
                break;
              case customerPlace:
                update.update((state) => searchPlace);
                break;
              default:
                update.update((state) => searchMobile);
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

  void _doMobileSearch(String mobileNumber) async {
    List<Transactions> showdowData = await BackEnd.fetchLatestTransactions();
    var result = showdowData.where((element) {
      if (element.mobileNumber.contains(mobileNumber)) {
        return true;
      } else {
        // _doReset();
        return false;
      }
    }).toList();
    ref.read(listOfTransactionsProvider.notifier).state = result;
  }

  void _doNameSearch(String name) async {
    List<Transactions> showdowData = await BackEnd.fetchLatestTransactions();
    var result = showdowData.where((element) {
      if (element.customerName.toLowerCase().contains(name.toLowerCase())) {
        return true;
      } else {
        return false;
      }
    }).toList();
    ref.read(listOfTransactionsProvider.notifier).state = result;
  }

  void _doPlaceSearch(String place) async {
    List<Transactions> showdowData = await BackEnd.fetchLatestTransactions();
    var result = showdowData.where((element) {
      if (element.address.toLowerCase().contains(place.toLowerCase())) {
        return true;
      } else {
        return false;
      }
    }).toList();
    ref.read(listOfTransactionsProvider.notifier).state = result;
  }
}
