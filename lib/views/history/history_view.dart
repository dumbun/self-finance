import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/user_history.dart';
import 'package:self_finance/providers/app_currency_provider.dart';
import 'package:self_finance/providers/history_provider.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/widgets/refresh_widget.dart';

class HistoryView extends ConsumerWidget {
  const HistoryView({super.key});

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
              enableIMEPersonalizedLearning: true,
              style: const TextStyle(
                color: AppColors.getPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
              keyboardType: TextInputType.name,
              onChanged: (value) => ref.read(asyncHistoryProvider.notifier).doSearch(givenInput: value),
            ),
            SizedBox(height: 16.sp),
            _buildhistoryList(),
          ],
        ),
      ),
    );
  }

  Consumer _buildhistoryList() {
    return Consumer(
      builder: (context, ref, child) {
        return ref.watch(asyncHistoryProvider).when(
              data: (List<UserHistory> data) {
                final String currencyType = ref.watch(currencyProvider);
                return Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return _buildListTile(data[index], currencyType);
                    },
                    itemCount: data.length,
                  ),
                );
              },
              error: (error, stackTrace) => Text(error.toString()),
              loading: () => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            );
      },
    );
  }

  ListTile _buildListTile(UserHistory data, String currencyType) {
    return ListTile(
      leading: _buildIcon(type: data.eventType),
      title: _buildAmount(data.eventType, data.amount, currencyType),
      subtitle: BodyTwoDefaultText(
        text: data.customerName,
        color: AppColors.getLigthGreyColor,
        bold: true,
      ),
      trailing: _buildDate(data.eventDate),
    );
  }

  BodyOneDefaultText _buildAmount(String type, double amount, String currencyType) {
    return BodyOneDefaultText(
      bold: true,
      text: "${type == Constant.debited ? "- " : "+ "}${Utility.doubleFormate(amount)} $currencyType",
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
}
