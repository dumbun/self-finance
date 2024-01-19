import 'package:flutter/material.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/views/Add%20New%20Entry/add_new_entry_view.dart';
import 'package:self_finance/views/Add%20New%20Entry/add_to_existing_contact_detailed_view.dart';
import 'package:self_finance/views/Add%20New%20Entry/add_to_existing_contact_view.dart';
import 'package:self_finance/views/dashboard_view.dart';
import 'package:self_finance/views/details_view.dart';
import 'package:self_finance/views/pin_creating_view.dart';
import 'package:self_finance/views/image_view.dart';
import 'package:self_finance/views/user_creating_view.dart';

class Routes {
  final BuildContext context;
  const Routes({required this.context});

  static navigateToAddTransactionToExistingContactDetailedView(BuildContext context,
      {required Customer customer, required List<Items> items, required List<Trx> transacrtions}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AddToExistingContactDetailedView(customer: customer, items: items, transacrtions: transacrtions),
      ),
    );
  }

  static navigateToAddNewTransactionToExistingContactView(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddTransactionToExistingContact(),
      ),
    );
  }

  static navigateToUserCreationView(BuildContext context, String pin) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => UserCreationView(pin: pin),
        ),
        (route) => false);
  }

  static navigateToPinCreationView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PinCreatingView(),
      ),
    );
  }

  static navigateToDashboard({required BuildContext context}) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => const DashboardView(),
        ),
        (route) => false);
  }

  static navigateToDetailsView({required BuildContext context, required Trx data}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => DetailsView(data: data),
      ),
    );
  }

  static navigateToImageView({required BuildContext context, required String imageData, required String titile}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => ImageView(imageString: imageData, titile: titile),
      ),
    );
  }

  static navigateToAddNewEntry({required BuildContext context}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(
          name: "add new transacrtion with new contact",
        ),
        builder: (context) => const AddNewEntery(),
      ),
    );
  }
}
