import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/widgets/detail_card_widget.dart';

import 'package:self_finance/widgets/title_widget.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  List<Customer> _data = [];

  void _getData() async {
    List<Customer> data = await BackEnd.fetchLatestTransactions();
    setState(() {
      _data = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  void dispose() {
    _data;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 8.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitleWidget(text: history),
          SizedBox(height: 18.sp),
          _buildSearchBar(),
          SizedBox(height: 18.sp),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, i) {
                return _buildHistoryTails(_data[i]);
              },
              itemCount: _data.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SearchAnchor(
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          elevation: const MaterialStatePropertyAll(0),
          hintText: "search using mobile number",
          controller: controller,
          padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 16.0.sp, vertical: 2.sp)),
          onTap: () {
            controller.openView();
          },
          onChanged: (_) {
            controller.openView();
          },
          leading: const Icon(Icons.search),
          trailing: [
            IconButton(
              onPressed: () {
                //todo run the search
                print(controller.text);
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
          _data.length,
          (int index) {
            final String item = _data[index].mobileNumber;
            return ListTile(
              title: Text(item),
              onTap: () {
                setState(
                  () {
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

  Widget _buildHistoryTails(Customer e) {
    return DetailCardWidget(customer: e);
  }
}
