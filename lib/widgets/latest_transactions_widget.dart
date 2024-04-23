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
    final String appCurrency = ref.watch(currencyProvider);

    return ref.watch(asyncHistoryProvider).when(
          data: (List<UserHistory> data) {
            if (data.isEmpty) {
              return const SizedBox();
            }
            return Expanded(
              child: ListView.builder(
                itemCount: data.length > 4 ? 4 : data.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 0,
                    child: Padding(
                      padding: EdgeInsets.all(4.sp),
                      child: ListTile(
                        leading: data[index].eventType == Constant.debited
                            ? const Icon(
                                Icons.arrow_upward_rounded,
                                color: AppColors.getErrorColor,
                              )
                            : const Icon(
                                Icons.arrow_downward_rounded,
                                color: AppColors.getGreenColor,
                              ),
                        title: BodyOneDefaultText(
                          text: '${data[index].amount} $appCurrency',
                          bold: true,
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
            );
          },
          error: (error, stackTrace) => const BodyTwoDefaultText(
            text: Constant.error,
          ),
          loading: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        );
  }
}
