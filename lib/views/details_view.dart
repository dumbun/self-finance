import 'package:flutter/material.dart';
import 'package:self_finance/models/transaction_model.dart';

class DetailsView extends StatelessWidget {
  const DetailsView({super.key, required this.data});

  final Transactions data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //todo details view
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
