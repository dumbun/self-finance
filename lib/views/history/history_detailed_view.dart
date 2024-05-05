import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:screenshot/screenshot.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history.dart';
import 'package:self_finance/providers/app_currency_provider.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';

class HistoryDetailedView extends ConsumerWidget {
  HistoryDetailedView({
    super.key,
    required this.customer,
    required this.history,
    required this.transaction,
  });
  final Customer customer;
  final UserHistory history;
  final Trx transaction;
  final ScreenshotController _screenshotController = ScreenshotController();

  String _getDate() {
    return "${DateFormat.yMMMMEEEEd().format(DateTime.parse(history.eventDate))} ${DateFormat.Hm().format(DateTime.parse(history.eventDate))}";
  }

  Card _buildDetailesCard({
    required IconData icon,
    required String title,
    required String details,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: BodyTwoDefaultText(
          text: title,
        ),
        trailing: BodyTwoDefaultText(
          bold: true,
          text: details,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String appCurrency = ref.read(currencyProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Utility.screenShotShare(_screenshotController, context),
        child: const Icon(Icons.share_rounded),
      ),
      appBar: AppBar(
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        child: Screenshot(
          controller: _screenshotController,
          child: Padding(
            padding: EdgeInsets.all(8.0.sp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 18.sp),
                  padding: EdgeInsets.symmetric(horizontal: 18.0.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            '${history.eventType == Constant.debited ? '-' : '+'} ${history.amount.toString()} $appCurrency',
                          ),
                          GestureDetector(
                            onTap: () => Routes.navigateToContactDetailsView(
                              context,
                              customerID: history.customerID,
                            ),
                            child: BodyOneDefaultText(
                              bold: true,
                              color: AppColors.getPrimaryColor,
                              text: '${history.eventType == Constant.debited ? 'To' : 'From'} ${customer.name}',
                            ),
                          ),
                          BodyTwoDefaultText(
                            text: _getDate(),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 40.sp,
                        width: 40.sp,
                        child: CircularImageWidget(
                          imageData: customer.photo,
                          titile: "${customer.name} photo",
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.sp,
                ),
                _buildDetailesCard(
                  icon: Icons.percent_rounded,
                  title: Constant.rateOfIntrest,
                  details: transaction.intrestRate.toString(),
                ),
                _buildDetailesCard(
                  icon: Icons.circle,
                  title: 'Tranasction Status',
                  details: Constant.active,
                ),
                Center(
                  child: TextButton(
                    onPressed: () => Routes.navigateToTransactionDetailsView(
                      transacrtion: transaction,
                      context: context,
                      customerDetails: customer,
                    ),
                    child: const BodyOneDefaultText(
                      text: 'Show trancation',
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
