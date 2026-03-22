import 'package:flutter/material.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/user_history_model.dart';
import 'package:self_finance/views/Add%20New%20Entry/customer_conformation_view.dart';
import 'package:self_finance/views/Add%20New%20Entry/customer_details_entry_view.dart';
import 'package:self_finance/views/Add%20New%20Entry/customer_lone_entry_view.dart';
import 'package:self_finance/views/account_setting_view.dart';
import 'package:self_finance/views/add_new_transaction_view.dart';
import 'package:self_finance/views/contact_details_view.dart';
import 'package:self_finance/views/contacts_view.dart';
import 'package:self_finance/views/customer_editind_view.dart';
import 'package:self_finance/views/dashboard_view.dart';
import 'package:self_finance/views/history/history_detailed_view.dart';
import 'package:self_finance/views/image_view.dart';
import 'package:self_finance/views/pin_auth_view.dart';
import 'package:self_finance/views/pin_creating_view.dart';
import 'package:self_finance/views/transaction_detail_view.dart';
import 'package:self_finance/views/user_creating_view.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> namedRoutes = {
    Constant.pinAuthView: (BuildContext context) => const PinAuthView(),
    Constant.dashboardView: (BuildContext context) => const DashboardView(),
    Constant.addNewEntryView: (BuildContext context) =>
        const CustomerDetailsEntryView(),
    Constant.contactView: (BuildContext context) => const ContactsView(),
    Constant.accountSettingsView: (BuildContext context) =>
        const AccountSettingsView(),
    Constant.pinCreatingView: (BuildContext context) => const PinCreatingView(),
  };

  static void navigateToTransactionDetailsView({
    required int transacrtionId,
    required int customerId,
    required BuildContext context,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            TransactionDetailView(transactionId: transacrtionId),
      ),
    );
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

  static void navigateToPinAuthView({required BuildContext context}) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(Constant.pinAuthView, (route) => false);
  }

  static void navigateToAccountSettingsView({required BuildContext context}) {
    Navigator.of(context).pushNamed(Constant.accountSettingsView);
  }

  static void navigateToAddNewTransactionToCustomerView({
    required BuildContext context,
    required int customerID,
  }) async {
    final List<Customer> res = await BackEnd.fetchSingleContactDetails(
      id: customerID,
    );
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddNewTransactionView(
            customerName: res.first.name,
            customerNumber: res.first.name,
            customerID: customerID,
          ),
        ),
      );
    }
  }

  static void navigateToContactEditingView({
    required BuildContext context,
    required Customer customer,
  }) async {
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => ContactEditingView(contact: customer),
        ),
        (route) => true,
      );
    }
  }

  static void navigateToContactDetailsView(
    BuildContext context, {
    required int customerID,
  }) {
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
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => UserCreatingView(pin: pin)),
      (route) => false,
    );
  }

  static void navigateToDashboard({required BuildContext context}) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      Constant.dashboardView,
      (Route<dynamic> route) => false,
    );
  }

  static void navigateToImageView({
    required BuildContext context,
    required String titile,
    required String imagePath,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) =>
            ImageView(titile: titile, imagePath: imagePath),
      ),
    );
  }

  static void navigateToHistoryDetailedView({
    required BuildContext context,
    required UserHistory history,
  }) async {
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) =>
              HistoryDetailedView(history: history),
        ),
      );
    }
  }

  static void navigateToAddNewEntry({required BuildContext context}) async {
    Navigator.of(context).pushNamed(Constant.addNewEntryView);
  }
}
