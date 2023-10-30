import 'package:flutter/material.dart';
import 'package:self_finance/models/customer_model.dart';

class DetailsView extends StatelessWidget {
  const DetailsView({super.key, required this.customer});

  final Customer customer;

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
            Text(customer.customerName),
            Text(customer.address),
            Text(customer.mobileNumber),
            Text(customer.takenDate),
            Text(customer.takenAmount.toString()),
          ],
        ),
      ),
    );
  }
}
