import 'dart:ffi';

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
  late Future<List<Transactions>> _dataFuture;
  List<Transactions> _shodowData = [];

  @override
  void initState() {
    super.initState();
    _dataFuture = BackEnd.fetchLatestTransactions();
  }

  Widget _showErrorAlert(error) {
    return AlertDilogs.alertDialogWithOneAction(context, "error", 'Error fetching data: $error');
  }

  @override
  void dispose() {
    _dataFuture;
    _shodowData;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 12.sp),
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
          return _showErrorAlert(snapshot.error);
        } else {
          _shodowData = snapshot.data ?? [];
          return _buildCards(snapshot.data ?? []);
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

  Widget _buildSearchBar() {
    return SearchAnchor(
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          elevation: MaterialStatePropertyAll(0.sp),
          hintText: "search using mobile number",
          controller: controller,
          padding: MaterialStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0.sp, vertical: 2.sp),
          ),
          onTap: () {
            _doSearch(controller.text);
          },
          onChanged: (_) {
            _doSearch(controller.text);
          },
          leading: const Icon(Icons.search),
          trailing: [
            IconButton(
              onPressed: () {
                _doSearch(controller.text);
              },
              icon: const Icon(
                Icons.arrow_circle_right_outlined,
                color: getPrimaryColor,
              ),
              selectedIcon: const Icon(Icons.arrow_circle_right),
            ),
          ],
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
      if (mobileNumber.isEmpty) {
        setState(() {
          _dataFuture = BackEnd.fetchLatestTransactions();
        });
      } else {
        List<Transactions> queryData = await BackEnd.getTransactionsEntriesByMobileNumber(mobileNumber);
        setState(() {
          _dataFuture = Future.value(queryData);
        });
      }
    } catch (error) {
      _showErrorAlert(error);
    }
  }
}
