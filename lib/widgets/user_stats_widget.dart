import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/providers/active_transaction_amount_provider.dart';
import 'package:self_finance/providers/app_currency_provider.dart';
import 'package:self_finance/theme/app_colors.dart';

class UserStatsWidget extends StatelessWidget {
  const UserStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  return ref.watch(activeTransactionAmount).when(
                        data: (double data) {
                          final String appCurrency = ref.watch(currencyProvider);
                          return _buildCard(title: "Active Amount", value: '${data.toString()} $appCurrency');
                        },
                        error: (error, stackTrace) => const BodyTwoDefaultText(
                          text: Constant.error,
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                },
              ),
              _buildCard(title: "Acquired Money", value: "250000"),
              _buildCard(title: "Completed Transaction", value: "250000"),
            ],
          ),
        ),
        SizedBox(height: 18.sp),
        const BodyOneDefaultText(
          text: "Recent Activities",
          bold: true,
        ),
        SizedBox(height: 8.sp),
      ],
    );
  }

  Card _buildCard({
    required String title,
    required String value,
  }) {
    return Card(
      color: AppColors.getPrimaryColor,
      elevation: 0.sp,
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Column(
          children: [
            BodyTwoDefaultText(
              text: title,
              color: AppColors.getBackgroundColor,
            ),
            BodyTwoDefaultText(
              color: AppColors.getBackgroundColor,
              text: value,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}
