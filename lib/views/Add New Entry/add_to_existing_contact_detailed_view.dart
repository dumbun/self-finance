import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class AddToExistingContactDetailedView extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
                SizedBox(height: 20.sp),
                _buildCustomerName(),
                SizedBox(height: 20.sp),
                _buildNumberDetails(),
              ],
            ),
          ),
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
                  const BodyTwoDefaultText(text: "Contact Number"),
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
  Container _buildImage() {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      margin: EdgeInsets.only(top: 20.sp),
      child: CircularImageWidget(imageData: customer.photo, titile: "customer photo"),
    );
  }
}
