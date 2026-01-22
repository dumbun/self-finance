import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:screenshot/screenshot.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history_model.dart';
import 'package:self_finance/providers/customer_contacts_provider.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/title_widget.dart';

class HistoryDetailedView extends StatelessWidget {
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
        title: BodyTwoDefaultText(text: title),
        trailing: BodyTwoDefaultText(bold: true, text: details),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Utility.screenShotShare(_screenshotController, context),
        child: const Icon(Icons.share_rounded),
      ),
      appBar: AppBar(forceMaterialTransparency: true),
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
                          Row(
                            children: [
                              TitleWidget(
                                color: history.eventType == Constant.debited
                                    ? AppColors.getErrorColor
                                    : AppColors.getGreenColor,
                                text:
                                    '${history.eventType == Constant.debited ? '-' : '+'} ${Utility.doubleFormate(history.amount)} ',
                              ),
                              CurrencyWidget(
                                color: history.eventType == Constant.debited
                                    ? AppColors.getErrorColor
                                    : AppColors.getGreenColor,
                              ),
                            ],
                          ),

                          GestureDetector(
                            onTap: () => Routes.navigateToContactDetailsView(
                              context,
                              customerID: history.customerID,
                            ),
                            child: SizedBox(
                              width: 60.sp,
                              child: BodyOneDefaultText(
                                overflow: TextOverflow.ellipsis,
                                bold: true,
                                color: AppColors.getPrimaryColor,
                                text:
                                    '${history.eventType == Constant.debited ? 'To' : 'From'} ${customer.name}',
                              ),
                            ),
                          ),
                          BodyTwoDefaultText(text: _getDate()),
                        ],
                      ),
                      SizedBox(
                        height: 40.sp,
                        width: 40.sp,
                        child: Consumer(
                          builder: (context, ref, child) {
                            ref.watch(asyncCustomersContactsProvider);
                            return FutureBuilder(
                              future: BackEnd.fetchSingleContactDetails(
                                id: customer.id!,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasData &&
                                    snapshot.data != null) {
                                  return CircularImageWidget(
                                    imageData: snapshot.data!.first.photo,
                                    titile:
                                        "${snapshot.data!.first.name} photo",
                                  );
                                } else {
                                  return Text(snapshot.error.toString());
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.sp),
                _buildDetailesCard(
                  icon: Icons.percent_rounded,
                  title: Constant.rateOfIntrest,
                  details: transaction.intrestRate.toString(),
                ),
                _buildDetailesCard(
                  icon: Icons.circle,
                  title: Constant.transacrtionStatus,
                  details: transaction.transacrtionType == Constant.active
                      ? Constant.active
                      : Constant.inactive,
                ),
                SizedBox(height: 12.sp),
                SizedBox(height: 12.sp),
                Center(
                  child: TextButton(
                    onPressed: () => Routes.navigateToTransactionDetailsView(
                      transacrtion: transaction,
                      context: context,
                    ),
                    child: const BodyOneDefaultText(
                      text: Constant.showTransaction,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
