import 'package:flutter/material.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/views/add_new_entry_view.dart';
import 'package:self_finance/views/dashboard_view.dart';
import 'package:self_finance/views/details_view.dart';
import 'package:self_finance/views/pin_creating_view.dart';

class Routes {
  final BuildContext context;
  const Routes({required this.context});

  static navigateToPinCreationView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PinCreatingView(),
      ),
    );
  }

  static navigateToDashboard({required BuildContext context, required User user}) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => DashboardView(user: user),
        ),
        (route) => false);
  }

  static navigateToDetailsView({required BuildContext context, required Customer customer}) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => DetailsView(
            customer: customer,
          ),
        ),
        (route) => true);
  }

  static navigateToAddNewEntry({required BuildContext context}) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => const AddNewEntryView(),
        ),
        (route) => true);
  }
}
