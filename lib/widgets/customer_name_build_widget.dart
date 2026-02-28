import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/providers/customer_provider.dart';

class CustomerNameBuildWidget extends ConsumerWidget {
  const CustomerNameBuildWidget({super.key, required this.customerID});
  final int customerID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(customerProvider(customerID))
        .when(
          data: (Customer? customer) {
            if (customer == null) {
              return const BodyTwoDefaultText(text: 'Customer not found');
            }
            return BodyTwoDefaultText(
              text: customer.name,
              bold: true,
              color: AppColors.getLigthGreyColor,
            );
          },
          loading: () => const CircularProgressIndicator.adaptive(),
          error: (error, stack) => BodyTwoDefaultText(text: 'Error: $error'),
        );
  }
}
