import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/fonts/selectable_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/widgets/call_button_widget.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/core/fonts/title_widget.dart';
import 'package:self_finance/widgets/proof_button.dart';

class BuildCustomerDetailsWidget extends ConsumerWidget {
  const BuildCustomerDetailsWidget({super.key, required this.customerID});
  final int customerID;

  Card _buildDetails(Widget icon, String title, String data) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(width: 12),
            icon,
            const SizedBox(width: 20),
            Column(
              mainAxisAlignment: title.isNotEmpty
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  BodyTwoDefaultText(
                    text: title,
                    color: AppColors.getLigthGreyColor,
                  ),
                const SizedBox(height: 8),
                SelectableTextWidget(data: data),
              ],
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildNumberDetails(String customerNumber) {
    return GestureDetector(
      onTap: () => Utility.makeCall(phoneNumber: customerNumber),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 12),
              CallButtonWidget(phoneNumber: customerNumber),
              const SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BodyTwoDefaultText(
                    text: "Contact Number",
                    color: AppColors.getLigthGreyColor,
                  ),
                  const SizedBox(height: 8),
                  SelectableTextWidget(data: customerNumber),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: ref
          .watch(customerProvider(customerID))
          .when(
            data: (Customer? customer) {
              if (customer != null) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    CircularImageWidget(
                      imageData: customer.photo,
                      titile: "${customer.name} photo",
                    ),
                    const SizedBox(height: 16),

                    // Customer Name
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Center(
                        child: TitleWidget(
                          textAlign: TextAlign.center,
                          text: customer.name,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildNumberDetails(customer.number),
                    const SizedBox(height: 12),
                    _buildDetails(
                      const Icon(
                        Icons.location_on,
                        color: AppColors.getPrimaryColor,
                      ),
                      Constant.customerAddress,
                      customer.address,
                    ),
                    const SizedBox(height: 12),
                    _buildDetails(
                      const Icon(
                        Icons.family_restroom,
                        color: AppColors.getPrimaryColor,
                      ),
                      Constant.guardianName,
                      customer.guardianName,
                    ),
                    const SizedBox(height: 12),
                    if (customer.proof.isNotEmpty)
                      ProofButton(proofImagePath: customer.proof),
                  ],
                );
              } else {
                return const BodyTwoDefaultText(
                  text: Constant.errorFetchingContactMessage,
                  error: true,
                );
              }
            },
            error: (Object error, StackTrace stackTrace) => const Center(
              child: BodyOneDefaultText(
                text: Constant.errorFetchingContactMessage,
              ),
            ),
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
          ),
    );
  }
}
