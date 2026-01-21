import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/user_history_model.dart';
import 'package:self_finance/providers/history_provider.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/refresh_widget.dart';

class HistoryView extends ConsumerWidget {
  const HistoryView({super.key});

  Row _buildAmount(String type, double amount) {
    return Row(
      children: [
        BodyOneDefaultText(
          bold: true,
          text: "${Utility.doubleFormate(amount)} ",
        ),
        CurrencyWidget(),
      ],
    );
  }

  Column _buildDate(String eventDate) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          DateFormat.yMMMd().format(DateTime.parse(eventDate)),
          softWrap: true,
          style: TextStyle(color: AppColors.getLigthGreyColor, fontSize: 14.sp),
        ),
        Text(
          DateFormat.Hm().format(DateTime.parse(eventDate)),
          softWrap: true,
          style: TextStyle(color: AppColors.getLigthGreyColor, fontSize: 14.sp),
        ),
      ],
    );
  }

  SizedBox _buildIcon({required String type}) {
    return type == Constant.debited
        ? SizedBox(
            height: 26.sp,
            width: 26.sp,
            child: Icon(
              color: AppColors.getErrorColor,
              Icons.arrow_upward_rounded,
              size: 22.sp,
            ),
          )
        : SizedBox(
            height: 26.sp,
            width: 26.sp,
            child: Icon(
              color: AppColors.getGreenColor,
              Icons.arrow_downward_rounded,
              size: 22.sp,
            ),
          );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshWidget(
      onRefresh: () => ref.refresh(asyncHistoryProvider.future),
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoSearchTextField(
              autocorrect: false,
              style: const TextStyle(
                color: AppColors.getPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
              keyboardType: TextInputType.name,
              onChanged: (String value) => ref
                  .read(asyncHistoryProvider.notifier)
                  .doSearch(givenInput: value),
            ),
            SizedBox(height: 12.sp),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                return ref
                    .watch(asyncHistoryProvider)
                    .when(
                      data: (List<UserHistory> data) => Expanded(
                        child: ListView.builder(
                          itemBuilder: (BuildContext context, int index) {
                            final UserHistory curr = data[index];
                            return ListTile(
                              onTap: () => Routes.navigateToHistoryDetailedView(
                                context: context,
                                customerID: curr.customerID,
                                history: curr,
                                transactionID: curr.transactionID,
                              ),

                              leading: _buildIcon(type: curr.eventType),
                              title: _buildAmount(curr.eventType, curr.amount),
                              subtitle: BodyTwoDefaultText(
                                text: curr.customerName,
                                color: AppColors.getLigthGreyColor,
                                bold: true,
                              ),
                              trailing: _buildDate(curr.eventDate),
                            );
                          },
                          itemCount: data.length,
                        ),
                      ),
                      error: (Object error, StackTrace stackTrace) =>
                          Text(error.toString()),
                      loading: () => const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
