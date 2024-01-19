import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/widgets/call_button_widget.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/title_widget.dart';

class AddToExistingContactDetailedView extends StatelessWidget {
  const AddToExistingContactDetailedView({
    super.key,
    required this.customer,
    required this.transacrtions,
    required this.items,
  });
  final Customer customer;
  final List<Trx> transacrtions;
  final List<Items> items;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BodyTwoDefaultText(text: customer.name),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildImage(),
                SizedBox(height: 16.sp),
                _buildCustomerName(),
                SizedBox(height: 16.sp),
                _buildNumberDetails(),
                SizedBox(height: 12.sp),
                _buildDetails(
                  const Icon(
                    Icons.location_on,
                    color: AppColors.getPrimaryColor,
                  ),
                  "Contact Address",
                  customer.address,
                ),
                SizedBox(height: 12.sp),
                _buildDetails(
                    const Icon(
                      Icons.family_restroom,
                      color: AppColors.getPrimaryColor,
                    ),
                    "Gaurdian",
                    customer.guardianName),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildDetails(Widget icon, String title, String data) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 12.sp),
            icon,
            SizedBox(width: 20.sp),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyTwoDefaultText(
                  text: title,
                  color: AppColors.getLigthGreyColor,
                ),
                SizedBox(height: 8.sp),
                SelectableText(
                  data,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18.sp,
                    fontFamily: "hell",
                    color: AppColors.getPrimaryColor,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildNumberDetails() {
    return GestureDetector(
      onTap: () => Utility.makeCall(phoneNumber: customer.number),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 12.sp),
              CallButtonWidget(phoneNumber: customer.number),
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
                  SelectableText(
                    customer.number,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 18.sp,
                      fontFamily: "hell",
                      color: AppColors.getPrimaryColor,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Center _buildCustomerName() {
    return Center(
      child: TitleWidget(
        text: customer.name,
      ),
    );
  }

  /// [ _buildImage()] method to build the image of the customer
  Center _buildImage() {
    return Center(child: CircularImageWidget(imageData: customer.photo, titile: "customer photo"));
  }
}
