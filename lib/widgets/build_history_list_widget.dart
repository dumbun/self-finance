import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/user_history_model.dart';
import 'package:self_finance/providers/history_provider.dart';
import 'package:self_finance/widgets/currency_widget.dart';

class BuildHistoryListWidget extends ConsumerWidget {
  const BuildHistoryListWidget({super.key});

  Column _buildDate(String eventDate) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        BodySmallText(
          text: DateFormat.yMMMd().format(DateTime.parse(eventDate)),
          color: AppColors.getLigthGreyColor,
        ),
        BodySmallText(
          text: DateFormat.Hm().format(DateTime.parse(eventDate)),
          color: AppColors.getLigthGreyColor,
        ),
      ],
    );
  }

  Icon _buildIcon({required String type}) {
    return type == Constant.debited
        ? Icon(
            color: AppColors.getErrorColor,
            Icons.arrow_upward_rounded,
            size: 22.sp,
          )
        : Icon(
            color: AppColors.getGreenColor,
            Icons.arrow_downward_rounded,
            size: 22.sp,
          );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(historyProvider)
        .when(
          data: (List<UserHistory> data) {
            if (data.isNotEmpty) {
              return ListView.builder(
                shrinkWrap: true, // ← important
                itemBuilder: (BuildContext context, int index) {
                  final UserHistory curr = data[index];
                  return ListTile(
                    key: ValueKey(curr.id),
                    onTap: () => Routes.navigateToHistoryDetailedView(
                      context: context,
                      history: curr,
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
                    trailing: _buildDate(curr.eventDate.toString()),
                  );
                },
                itemCount: data.length,
              );
            } else {
              return const Center(
                child: BodyOneDefaultText(
                  bold: true,
                  text: "No histroy to view",
                ),
              );
            }
          },
          error: (Object error, StackTrace stackTrace) =>
              BodySmallText(text: error.toString()),
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
        );
  }
}
