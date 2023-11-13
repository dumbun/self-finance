import 'package:flutter/material.dart';
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
            Utility.imageFromBase64String(data.photoCustomer),
            Utility.imageFromBase64String(data.photoProof),
            Utility.imageFromBase64String(data.photoItem),
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
}
