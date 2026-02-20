import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/widgets/build_customer_details_widget.dart';
import 'package:self_finance/widgets/customer_transactions_widget.dart';
import 'package:self_finance/widgets/fab.dart';
import 'package:self_finance/widgets/popup_menu_widget.dart';

class ContactDetailsView extends StatelessWidget {
  const ContactDetailsView({super.key, required this.customerID});
  final int customerID;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        floatingActionButton: Fab(
          icon: Icons.add,
          heroTag: Constant.saveButtonTag,
          onPressed: () => Routes.navigateToAddNewTransactionToCustomerView(
            context: context,
            customerID: customerID,
          ),
        ),
        appBar: AppBar(
          forceMaterialTransparency: true,
          actions: [PopupMenuWidget(customerId: customerID)],
          toolbarHeight: 32.sp,
          title: const BodyTwoDefaultText(text: "Contact Info", bold: true),
          bottom: const TabBar(
            dividerColor: Colors.transparent,
            tabs: <Widget>[
              Tab(icon: Icon(Icons.person)),
              Tab(icon: Icon(Icons.history)),
            ],
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 16.sp),
            child: TabBarView(
              children: <Widget>[
                BuildCustomerDetailsWidget(customerID: customerID),
                CustomerTransactionsWidget(customerId: customerID),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
