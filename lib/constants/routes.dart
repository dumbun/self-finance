import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/views/add_new_transaction_view.dart';
import 'package:self_finance/views/contact_details_view.dart';
import 'package:self_finance/views/customer_editind_view.dart';
import 'package:self_finance/views/pin_creating_view.dart';
import 'package:self_finance/views/image_view.dart';
import 'package:self_finance/views/transaction_detail_view.dart';
import 'package:self_finance/views/user_creating_view.dart';

class Routes {
  static void navigateToTransactionDetailsView({
    required Trx transacrtion,
    required BuildContext context,
  }) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => TransactionDetailView(
        transacrtion: transacrtion,
      ),
    ));
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

  static void navigateToImageView({required BuildContext context, required String imageData, required String titile}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => ImageView(imageString: imageData, titile: titile),
      ),
    );
  }

  static void navigateToAddNewEntry({required BuildContext context}) async {
    Navigator.of(context).pushNamed(Constant.addNewEntryView);
  }
}
