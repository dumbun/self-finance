import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history.dart';
import 'package:self_finance/providers/app_currency_provider.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/providers/history_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/widgets/ads_banner_widget.dart';
import 'package:self_finance/widgets/refresh_widget.dart';

class HistoryView extends ConsumerWidget {
  const HistoryView({super.key});

  BodyOneDefaultText _buildAmount(String type, double amount, String currencyType) {
    return BodyOneDefaultText(
      bold: true,
      text: "${Utility.doubleFormate(amount)} $currencyType",
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
    ListTile buildListTile(UserHistory data) {
      return ListTile(
        onTap: () =>
            ref.read(asyncCustomersProvider.notifier).fetchRequriedCustomerDetails(customerID: data.customerID).then(
                  (List<Customer> customer) => ref
                      .read(asyncTransactionsProvider.notifier)
                      .fetchRequriedTransaction(transactionId: data.transactionID)
                      .then((List<Trx> transaction) {
                    if (context.mounted) {
                      Routes.navigateToHistoryDetailedView(
                        context: context,
                        customer: customer.first,
                        history: data,
                        transaction: transaction.first,
                      );
                    }
                  }),
                ),
        leading: _buildIcon(type: data.eventType),
        title: _buildAmount(data.eventType, data.amount, ref.watch(currencyProvider)),
        subtitle: BodyTwoDefaultText(
          text: data.customerName,
          color: AppColors.getLigthGreyColor,
          bold: true,
        ),
        trailing: _buildDate(data.eventDate),
      );
    }

    Expanded buildhistoryList(List<UserHistory> data, currencyType) {
      return Expanded(
        child: ListView.builder(
          itemBuilder: (context, index) {
            return buildListTile(data[index]);
          },
          itemCount: data.length,
        ),
      );
    }

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
              onChanged: (String value) => ref.read(asyncHistoryProvider.notifier).doSearch(givenInput: value),
            ),
            SizedBox(height: 16.sp),
            const AdsBannerWidget(),
            SizedBox(height: 16.sp),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                return ref.watch(asyncHistoryProvider).when(
                      data: (List<UserHistory> data) => buildhistoryList(data, ref.watch(currencyProvider)),
                      error: (Object error, StackTrace stackTrace) => Text(error.toString()),
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
