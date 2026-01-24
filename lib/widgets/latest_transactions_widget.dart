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

final AutoDisposeFutureProvider<List<UserHistory>> latestUserHistoryProvider =
    FutureProvider.autoDispose((ref) async {
      return await ref.watch(asyncHistoryProvider.notifier).build();
    });

class LatestTransactionsWidget extends ConsumerWidget {
  const LatestTransactionsWidget({super.key});

  Column _buildDate(String eventDate) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        BodyTwoDefaultText(
          text: DateFormat.yMMMd().format(DateTime.parse(eventDate)),
          color: AppColors.getLigthGreyColor,
          bold: true,
        ),
        BodyTwoDefaultText(
          text: DateFormat.Hm().format(DateTime.parse(eventDate)),
          color: AppColors.getLigthGreyColor,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void navigateToHistoryDetailedView(int customerID, UserHistory history) {
      Routes.navigateToHistoryDetailedView(
        context: context,
        customerID: customerID,
        history: history,
        transactionID: history.transactionID,
      );
    }

    return ref
        .watch(asyncHistoryProvider)
        .when(
          data: (List<UserHistory> data) {
            if (data.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const BodyOneDefaultText(text: "Recent Activites", bold: true),
                SizedBox(height: 16.sp),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: false,
                    addAutomaticKeepAlives: true,
                    itemCount: data.length > 4 ? 4 : data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        elevation: 0,
                        child: Padding(
                          padding: EdgeInsets.all(4.sp),
                          child: ListTile(
                            onTap: () => navigateToHistoryDetailedView(
                              data[index].customerID,
                              data[index],
                            ),
                            leading: data[index].eventType == Constant.debited
                                ? const Icon(
                                    Icons.arrow_upward_rounded,
                                    color: AppColors.getErrorColor,
                                  )
                                : const Icon(
                                    Icons.arrow_downward_rounded,
                                    color: AppColors.getGreenColor,
                                  ),
                            title: Row(
                              children: [
                                BodyOneDefaultText(
                                  text:
                                      '${Utility.doubleFormate(data[index].amount)} ',
                                  bold: true,
                                ),
                                CurrencyWidget(),
                              ],
                            ),
                            subtitle: BodyTwoDefaultText(
                              text: data[index].customerName,
                              bold: true,
                              color: AppColors.getLigthGreyColor,
                            ),
                            trailing: _buildDate(data[index].eventDate),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          error: (Object error, StackTrace stackTrace) =>
              const BodyTwoDefaultText(text: Constant.error),
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
        );
  }
}
