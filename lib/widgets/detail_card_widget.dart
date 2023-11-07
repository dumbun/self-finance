import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/transaction_model.dart';

import 'package:self_finance/widgets/arrow_widge.dart';
import 'package:self_finance/widgets/default_user_image.dart';

class DetailCardWidget extends StatelessWidget {
  const DetailCardWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  final Transactions data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 12.0.sp,
        vertical: 6.0.sp,
      ),
      width: double.infinity,
      child: Card(
        elevation: 0.0,
        child: InkWell(
          onTap: () => Routes.navigateToDetailsView(context: context, data: data),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 18.0.sp,
              horizontal: 16.0.sp,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const DefaultUserImage(),
                      SizedBox(width: 16.0.sp),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          BodyTwoDefaultText(
                            text: data.customerName,
                            bold: true,
                          ),
                          SizedBox(height: 8.0.sp),
                          BodyTwoDefaultText(text: data.takenDate),
                          SizedBox(height: 8.0.sp),
                          Row(
                            children: [
                              const BodyTwoDefaultText(text: "amount - taken : "),
                              BodyTwoDefaultText(
                                bold: true,
                                text: data.takenAmount.toString(),
                                error: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                getArrowIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
