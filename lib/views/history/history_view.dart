import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/user_history_model.dart';
import 'package:self_finance/providers/history_provider.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/refresh_widget.dart';

class HistoryView extends ConsumerStatefulWidget {
  const HistoryView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HistoryViewState();
}

class _HistoryViewState extends ConsumerState<HistoryView> {
  final TextEditingController _controller = TextEditingController();

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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshWidget(
      onRefresh: () => ref.refresh(asyncHistoryProvider.future),
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoSearchTextField(
              controller: _controller,
              suffixInsets: EdgeInsetsGeometry.all(12.sp),
              suffixIcon: Icon(Icons.calendar_month, size: 22.sp),
              suffixMode: OverlayVisibilityMode.always,
              onSuffixTap: () async {
                _controller.clear();
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  currentDate: DateTime.now(),
                  keyboardType: TextInputType.datetime,
                  switchToCalendarEntryModeIcon: Icon(Icons.calendar_month),
                  firstDate: DateTime(1900),
                  //DateTime.now() - not to allow to choose before today.
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  //pickedDate output format => 2021-03-10 00:00:00.000
                  String formattedDate = DateFormat(
                    'dd-MM-yyyy',
                  ).format(pickedDate);
                  _controller.text = formattedDate;
                }
              },
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
            Expanded(
              child: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  return ref
                      .watch(asyncHistoryProvider)
                      .when(
                        data: (List<UserHistory> data) {
                          if (data.isNotEmpty) {
                            return ListView.builder(
                              shrinkWrap: true, // ← important
                              itemBuilder: (BuildContext context, int index) {
                                final UserHistory curr = data[index];
                                return ListTile(
                                  onTap: () =>
                                      Routes.navigateToHistoryDetailedView(
                                        context: context,
                                        customerID: curr.customerID,
                                        history: curr,
                                        transactionID: curr.transactionID,
                                      ),

                                  leading: _buildIcon(type: curr.eventType),
                                  title: CurrencyWidget(
                                    amount: Utility.doubleFormate(curr.amount),
                                  ),
                                  subtitle: BodyTwoDefaultText(
                                    text: curr.customerName,
                                    color: AppColors.getLigthGreyColor,
                                    bold: true,
                                  ),
                                  trailing: _buildDate(curr.eventDate),
                                );
                              },
                              itemCount: data.length,
                            );
                          } else {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  BodyOneDefaultText(
                                    bold: true,
                                    text: "No histroy to view",
                                  ),
                                  Icon(
                                    Icons.web_asset_off,
                                    size: 80.sp,
                                    color: AppColors.getLigthGreyColor,
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        error: (Object error, StackTrace stackTrace) =>
                            Text(error.toString()),
                        loading: () => const Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
