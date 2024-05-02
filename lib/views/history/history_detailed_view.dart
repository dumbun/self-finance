import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/user_history.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';

class HistoryDetailedView extends StatelessWidget {
  const HistoryDetailedView({super.key, required this.customer, required this.history});
  final Customer customer;
  final UserHistory history;

  String _getDate() {
    return "${DateFormat.yMMMMEEEEd().format(DateTime.parse(history.eventDate))} ${DateFormat.Hm().format(DateTime.parse(history.eventDate))}";
  }

  Card _buildCustomerDetails() {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 20.sp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyTwoDefaultText(
                  text: customer.name,
                  bold: true,
                ),
                BodyTwoDefaultText(
                  text: customer.number,
                  color: AppColors.getLigthGreyColor,
                ),
                BodyTwoDefaultText(
                  text: customer.address,
                  color: AppColors.getLigthGreyColor,
                ),
              ],
            ),
            CircularImageWidget(
              imageData: customer.photo,
              titile: "${customer.name} photo",
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BodyTwoDefaultText(
          text: _getDate(),
          bold: true,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0.sp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildCustomerDetails(),
            ],
          ),
        ),
      ),
    );
  }
}
