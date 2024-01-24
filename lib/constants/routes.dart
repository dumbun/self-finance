import 'package:flutter/material.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/views/contact_details_view.dart';
import 'package:self_finance/views/customer_editind_view.dart';
import 'package:self_finance/views/details_view.dart';
import 'package:self_finance/views/pin_creating_view.dart';
import 'package:self_finance/views/image_view.dart';
import 'package:self_finance/views/user_creating_view.dart';

class Routes {
  static void navigateToContactEditingView({required BuildContext context, required Customer contact}) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => ContactEditingView(contact: contact)),
      (route) => true,
    );
  }

  static void navigateToContactDetailsView(BuildContext context,
      {required Customer customer, required List<Items> items, required List<Trx> transacrtions}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContactDetailsView(customer: customer, items: items, transacrtions: transacrtions),
      ),
    );
  }

  static void navigateToContactsView(BuildContext context) {
    Navigator.of(context).pushNamed('/contactsView');
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
    Navigator.of(context).pushNamed('/dashboardview');
  }

  static void navigateToDetailsView({required BuildContext context, required Trx data}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => DetailsView(data: data),
      ),
    );
  }

  static void navigateToImageView({required BuildContext context, required String imageData, required String titile}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => ImageView(imageString: imageData, titile: titile),
      ),
    );
  }

  static void navigateToAddNewEntry({required BuildContext context}) {
    Navigator.of(context).pushNamed('/addNewEntry');
  }
}
