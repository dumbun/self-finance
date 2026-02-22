import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/payment_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimelineWidget extends StatelessWidget {
  const TimelineWidget({
    super.key,
    required this.transaction,
    required this.payment,
  });
  final Trx transaction;
  final Payment payment;
  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey("TimeLineWidget"),
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyTwoDefaultText(
                color: AppColors.contentColorBlue,
                bold: true,
                text: Constant.history.toUpperCase(),
              ),
              SizedBox(height: 14.sp),

              TimelineTile(
                alignment: TimelineAlign.start,
                lineXY: 0.08, // position of the line
                isFirst: true,
                isLast: false,
                indicatorStyle: const IndicatorStyle(width: 10),
                beforeLineStyle: const LineStyle(thickness: 2),
                afterLineStyle: const LineStyle(thickness: 2),
                endChild: Padding(
                  padding: EdgeInsets.all(12.sp),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyTwoDefaultText(
                        bold: true,
                        color: AppColors.getLigthGreyColor,
                        text: Utility.formatDate(
                          date: transaction.transacrtionDate,
                        ),
                      ),
                      Row(
                        children: [
                          const BodyTwoDefaultText(bold: true, text: "Bought "),
                          CurrencyWidget(
                            smallText: true,
                            amount: Utility.doubleFormate(transaction.amount),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                hasIndicator: true,
              ),
              TimelineTile(
                alignment: TimelineAlign.start,
                lineXY: 0.08, // position of the line
                isFirst: false,
                isLast: true,
                indicatorStyle: const IndicatorStyle(width: 10),
                beforeLineStyle: const LineStyle(thickness: 2),
                afterLineStyle: const LineStyle(thickness: 2),
                endChild: Padding(
                  padding: EdgeInsets.all(12.sp),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      BodyTwoDefaultText(
                        bold: true,
                        color: AppColors.getLigthGreyColor,
                        text: Utility.formatDate(date: payment.paymentDate),
                      ),

                      Row(
                        children: [
                          const BodyTwoDefaultText(bold: true, text: "Paid "),
                          CurrencyWidget(
                            smallText: true,
                            amount: Utility.doubleFormate(payment.amountpaid),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                hasIndicator: true,
              ),
              SizedBox(height: 14.sp),
            ],
          ),
        ),
      ],
    );
  }
}
