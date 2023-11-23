import 'package:flutter/material.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/util.dart';

class DetailsView extends StatelessWidget {
  const DetailsView({super.key, required this.data});

  final Transactions data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: getPrimaryTextColor,
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
            Text(data.id.toString()),
            Text(data.customerName),
            Text(data.via.toString()),
            Text(data.address),
            Text(data.mobileNumber),
            Text(data.takenDate),
            Text(data.takenAmount.toString()),
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
