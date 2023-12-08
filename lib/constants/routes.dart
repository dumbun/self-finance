import 'package:flutter/material.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/views/dashboard_view.dart';
import 'package:self_finance/views/details_view.dart';
import 'package:self_finance/views/pin_creating_view.dart';
import 'package:self_finance/views/image_view.dart';
import 'package:self_finance/views/user_creating_view.dart';

class Routes {
  final BuildContext context;
  const Routes({required this.context});

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

  static navigateToDetailsView({required BuildContext context, required Transactions data}) {
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
    Navigator.pushNamed(context, '/addNewEntry');
  }
}
