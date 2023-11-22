import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/widgets/detail_card_widget.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/title_widget.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({Key? key}) : super(key: key);

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  Future<List<Transactions>> _dataFuture = BackEnd.fetchLatestTransactions();
  List<Transactions> _shodowData = [];
  List<String> filters = ["Mobile Number", "Name"];

  @override
  void initState() {
    super.initState();
    _dataFuture = BackEnd.fetchLatestTransactions();
  }

  Widget _showErrorAlert(error) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AlertDilogs.alertDialogWithOneAction(context, "error", 'Error fetching data: $error');
    });

    // Return a placeholder widget, or an empty container
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 16.sp),
      child: RefreshIndicator.adaptive(
        onRefresh: () => _dataFuture = _dataFuture = BackEnd.fetchLatestTransactions(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TitleWidget(text: history),
            SizedBox(height: 18.sp),
            _buildSearchBar(),
            SizedBox(height: 18.sp),
            _buildData(),
          ],
        ),
      ),
    );
  }

  FutureBuilder<List<Transactions>> _buildData() {
    return FutureBuilder<List<Transactions>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive()); // Placeholder for loading state
        } else if (snapshot.hasError) {
          // return Text(snapshot.error.toString());
          return _showErrorAlert(snapshot.error);
        } else {
          // Check if data is null or empty
          final List<Transactions>? data = snapshot.data;
          if (data == null || data.isEmpty) {
            return const Center(
              child: Text("No transactions found."),
            );
          }
          _shodowData = data;
          return _buildCards(data);
        }
      },
    );
  }

  Widget _buildCards(List<Transactions> data) {
    if (data.isEmpty || data == []) {
      return const Center(
        child: Text("No transactions found."),
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

  String dropdownValue = "Mobile Number";

  void _doChangeSearchFilters() {}

  Widget _buildSearchBar() {
    return SearchAnchor(
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          elevation: MaterialStatePropertyAll(0.sp),
          trailing: [
            DropdownButton(

              icon: const Icon(Icons.filter_alt_outlined),
              enableFeedback: true,
              items: filters.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              value: dropdownValue,
              onChanged: (String? value) {
                setState(() {
                  dropdownValue = value!;
                });
              },
            ),
          ],
          leading: const Icon(Icons.search),
          onSubmitted: (value) => _doSearch(controller.text),
          controller: controller,
          onChanged: (_) {
            _doSearch(controller.text);
          },
        );
      },
      isFullScreen: false,
      dividerColor: getPrimaryTextColor,
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        return List<ListTile>.generate(
          _shodowData.length,
          (int index) {
            final String item = _shodowData[index].mobileNumber;
            return ListTile(
              title: Text(item),
              onTap: () {
                setState(
                  () {
                    _doSearch(item);
                    controller.closeView(item);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _doSearch(String mobileNumber) async {
    try {
      List<Transactions> queryData = [];

      if (mobileNumber.isNotEmpty) {
        queryData = await BackEnd.getTransactionsEntriesByMobileNumber(mobileNumber);
      }

      setState(() {
        _dataFuture = Future.value(queryData);
      });
    } catch (error) {
      _showErrorAlert(error);
    }
  }
}
