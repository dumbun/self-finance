import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';

class CustomerCardWidget extends ConsumerWidget {
  const CustomerCardWidget({super.key, required this.customerId});
  final int customerId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () =>
          Routes.navigateToContactDetailsView(context, customerID: customerId),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: ref
              .watch(customerProvider(customerId))
              .when(
                data: (data) {
                  if (data == null) {
                    return const BodyTwoDefaultText(
                      text: Constant.errorFetchingContactMessage,
                    );
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularImageWidget(
                        customeSize: 32.sp,
                        imageData: data.photo,
                        titile: "Customer Photo",
                      ),
                      SizedBox(width: 16.sp),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BodyTwoDefaultText(
                            text: "Name: ${data.name}",
                            bold: true,
                          ),
                          BodyTwoDefaultText(
                            text: data.guardianName,
                            bold: true,
                          ),
                          BodyTwoDefaultText(
                            text: "From: ${data.address}",
                            bold: true,
                          ),
                          BodyTwoDefaultText(
                            text: "Phone: ${data.number}",
                            bold: true,
                          ),
                        ],
                      ),
                    ],
                  );
                },
                error: (error, stackTrace) => const BodyTwoDefaultText(
                  text: Constant.errorFetchingContactMessage,
                ),
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
              ),
        ),
      ),
    );
  }
}
