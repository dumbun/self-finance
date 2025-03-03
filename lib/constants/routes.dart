import 'package:flutter/material.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history.dart';
import 'package:self_finance/views/Add%20New%20Entry/customer_conformation_view.dart';
import 'package:self_finance/views/Add%20New%20Entry/customer_lone_entry_view.dart';
import 'package:self_finance/views/add_new_transaction_view.dart';
import 'package:self_finance/views/contact_details_view.dart';
import 'package:self_finance/views/customer_editind_view.dart';
import 'package:self_finance/views/history/history_detailed_view.dart';
import 'package:self_finance/views/pin_creating_view.dart';
import 'package:self_finance/views/image_view.dart';
import 'package:self_finance/views/transaction_detail_view.dart';
import 'package:self_finance/views/user_creating_view.dart';

class Routes {
  static void navigateToTransactionDetailsView({required Trx transacrtion, required BuildContext context}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => TransactionDetailView(
        transacrtion: transacrtion,
      ),
    ));
  }

  static void navigateToCustomerLoneEntryView({
    required BuildContext context,
    required String customerName,
    required String mobileNumber,
    required String gaurdianName,
    required String address,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => CustomerLoneEntryView(
          customerName: customerName,
          mobileNumber: mobileNumber,
          gaurdianName: gaurdianName,
          address: address,
        ),
      ),
    );
  }

  static void navigateToCustomerConformationView({
    required BuildContext context,
    required String customerName,
    required String mobileNumber,
    required String gaurdianName,
    required String address,
    required String itemDescription,
    required double rateOfIntrest,
    required double takenAmount,
    required String takenDate,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => CustomerConformationView(
          customerName: customerName,
          mobileNumber: mobileNumber,
          gaurdianName: gaurdianName,
          address: address,
          itemDescription: itemDescription,
          rateOfIntrest: rateOfIntrest,
          takenAmount: takenAmount,
          takenDate: takenDate,
        ),
      ),
    );
  }

  static void navigateToChangePinView({required BuildContext context}) {
    Navigator.of(context).pushNamed(Constant.changePinView);
  }

  static void navigateToAccountSettingsView({required BuildContext context}) {
    Navigator.of(context).pushNamed(Constant.accountSettingsView);
  }

  static void navigateToAddNewTransactionToCustomerView({required BuildContext context, required int customerID}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddNewTransactionView(customerID: customerID),
      ),
    );
  }

  static void navigateToContactEditingView({required BuildContext context, required Customer contact}) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => ContactEditingView(contact: contact)),
      (route) => true,
    );
  }

  static void navigateToContactDetailsView(BuildContext context, {required int customerID}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContactDetailsView(customerID: customerID),
      ),
    );
  }

  static void navigateToContactsView(BuildContext context) {
    Navigator.of(context).pushNamed(Constant.contactView);
  }

  static void navigateToUserCreationView(BuildContext context, String pin) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => UserCreationView(pin: pin),
        ),
        (route) => false);
  }

  static void navigateToPinCreationView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PinCreatingView(),
      ),
    );
  }

  static void navigateToDashboard({required BuildContext context}) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      Constant.dashboardView,
      (route) => false,
    );
  }

  static void navigateToImageView({
    required BuildContext context,
    required String titile,
    required Image imageWidget,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => ImageView(
          titile: titile,
          imageWidget: imageWidget,
        ),
      ),
    );
  }

  static void navigateToHistoryDetailedView({
    required BuildContext context,
    required Customer customer,
    required UserHistory history,
    required Trx transaction,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => HistoryDetailedView(
          customer: customer,
          history: history,
          transaction: transaction,
        ),
      ),
    );
  }

  static void navigateToAddNewEntry({required BuildContext context}) async {
    Navigator.of(context).pushNamed(Constant.addNewEntryView);
  }
}
