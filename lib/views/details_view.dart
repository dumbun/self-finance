import 'package:flutter/material.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/widgets/call_button_widget.dart';

class DetailsView extends StatelessWidget {
  const DetailsView({super.key, required this.data});

  final Transactions data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: getTransparentColor,
        title: BodyOneDefaultText(text: data.customerName),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _builtImageWidget(context, data.photoCustomer, customerPhoto),
            _builtImageWidget(context, data.photoProof, "Proof"),
            _builtImageWidget(context, data.photoItem, "Item"),
            BodyOneDefaultText(text: data.id.toString()),
            BodyOneDefaultText(text: data.customerName),
            BodyOneDefaultText(text: data.address),
            BodyOneDefaultText(text: data.mobileNumber),
            BodyOneDefaultText(text: data.itemName),
            BodyOneDefaultText(text: data.rateOfInterest.toString()),
            BodyOneDefaultText(text: data.takenDate),
            BodyOneDefaultText(text: data.takenAmount.toString()),
            CallButtonWidget(phoneNumber: data.mobileNumber),
          ],
        ),
      ),
    );
  }

  GestureDetector _builtImageWidget(BuildContext context, imageData, titile) {
    return GestureDetector(
        onTap: () {
          Routes.navigateToImageView(context: context, imageData: imageData, titile: titile);
        },
        child: Utility.imageFromBase64String(imageData));
  }
}
