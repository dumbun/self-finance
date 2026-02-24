import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
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

class BuildCustomerDetailsWidget extends ConsumerWidget {
  const BuildCustomerDetailsWidget({super.key, required this.customerID});

  Card _buildDetails(Widget icon, String title, String data) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(14.sp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 12.sp),
            icon,
            SizedBox(width: 20.sp),
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
                SizedBox(height: 8.sp),
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
          padding: EdgeInsets.all(14.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 12.sp),
              CallButtonWidget(phoneNumber: customerNumber),
              SizedBox(width: 20.sp),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BodyTwoDefaultText(
                    text: "Contact Number",
                    color: AppColors.getLigthGreyColor,
                  ),
                  SizedBox(height: 8.sp),
                  SelectableTextWidget(data: customerNumber),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// [ _buildImage()] method to build the image of the customer
  Center _buildImage(String imageData, String customerName) {
    return Center(
      child: CircularImageWidget(
        imageData: imageData,
        titile: "$customerName photo",
      ),
    );
  }

  final int customerID;

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 20.sp),

                    _buildImage(customer.photo, customer.name),
                    SizedBox(height: 16.sp),

                    // Customer Name
                    Padding(
                      padding: EdgeInsets.only(left: 20.sp, right: 20.sp),
                      child: Center(
                        child: TitleWidget(
                          textAlign: TextAlign.center,
                          text: customer.name,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.sp),

                    _buildNumberDetails(customer.number),
                    SizedBox(height: 12.sp),
                    _buildDetails(
                      const Icon(
                        Icons.location_on,
                        color: AppColors.getPrimaryColor,
                      ),
                      Constant.customerAddress,
                      customer.address,
                    ),
                    SizedBox(height: 12.sp),
                    _buildDetails(
                      const Icon(
                        Icons.family_restroom,
                        color: AppColors.getPrimaryColor,
                      ),
                      Constant.guardianName,
                      customer.guardianName,
                    ),
                    SizedBox(height: 12.sp),
                    if (customer.proof.isNotEmpty)
                      GestureDetector(
                        onTap: () => Routes.navigateToImageView(
                          context: context,
                          imagePath: customer.proof,
                          titile: "${customer.name} proof",
                        ),
                        child: Card(
                          elevation: 0,
                          child: Padding(
                            padding: EdgeInsets.all(14.sp),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(width: 12.sp),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: AppColors.getPrimaryColor,
                                ),
                                SizedBox(width: 20.sp),
                                const BodyOneDefaultText(
                                  text: "Show Customer proof",
                                  color: AppColors.getPrimaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              } else {
                return const Spacer();
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
