import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/filter_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/customer_name_build_widget.dart';
import 'package:self_finance/widgets/refresh_widget.dart';
import 'package:self_finance/widgets/transaction_filter_widget.dart';

class TransactionsView extends ConsumerStatefulWidget {
  const TransactionsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionsViewState();
}

class _TransactionsViewState extends ConsumerState<TransactionsView> {
  final TextEditingController _searchText = TextEditingController();

  @override
  void dispose() {
    _searchText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshWidget(
      onRefresh: () => ref.refresh(asyncTransactionsProvider.future),
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CupertinoSearchTextField(
              suffixInsets: EdgeInsetsGeometry.all(12.sp),

              onSuffixTap: () async {
                _searchText.clear();
                ref.read(filterProvider).clear();
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
                  setState(() {
                    _searchText.text = formattedDate;
                  });
                  ref
                      .read(asyncTransactionsProvider.notifier)
                      .fetchTransactionsByDate(formattedDate);
                } else {}
              },
              suffixIcon: Icon(Icons.calendar_month, size: 22.sp),
              suffixMode: OverlayVisibilityMode.always,
              controller: _searchText,
              autocorrect: false,
              onChanged: (String value) {
                ref.read(filterProvider.notifier).clear();
                ref
                    .read(asyncTransactionsProvider.notifier)
                    .doSearch(givenInput: value);
              },
              style: const TextStyle(
                color: AppColors.getPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
              keyboardType: TextInputType.name,
            ),
            SizedBox(height: 16.sp),
            TransactionFilterWidget(),
            SizedBox(height: 16.sp),
            // List Builder
            Expanded(
              child: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  return ref
                      .watch(asyncTransactionsProvider)
                      .when(
                        data: (List<Trx> data) {
                          if (data.isNotEmpty) {
                            return ListView.builder(
                              shrinkWrap: true, // ← important
                              itemCount: data.length, // ← important
                              itemBuilder: (context, index) {
                                final Trx txn = data[index];
                                return Card(
                                  elevation: 0,
                                  child: ListTile(
                                    onTap: () {
                                      Routes.navigateToTransactionDetailsView(
                                        transacrtionId: txn.id!,
                                        customerId: txn.customerId,
                                        context: context,
                                      );
                                    },
                                    leading: Icon(
                                      Icons.circle,
                                      color: txn.transacrtionType == 'Active'
                                          ? AppColors.contentColorGreen
                                          : AppColors.getErrorColor,
                                    ),
                                    title: CurrencyWidget(
                                      amount: Utility.doubleFormate(txn.amount),
                                    ),
                                    subtitle: CustomerNameBuildWidget(
                                      customerID: txn.customerId,
                                    ),
                                    trailing: BodyTwoDefaultText(
                                      text:
                                          '${txn.transacrtionDate}\nID: ${txn.id}',
                                      bold: true,
                                      color: AppColors.getLigthGreyColor,
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                BodyOneDefaultText(
                                  bold: true,
                                  text: "No Transactons to view",
                                ),
                                Icon(
                                  Icons.web_asset_off,
                                  size: 80.sp,
                                  color: AppColors.getLigthGreyColor,
                                ),
                              ],
                            );
                          }
                        },
                        error: (Object error, StackTrace stackTrace) =>
                            Text(error.toString()),
                        loading: () => const CircularProgressIndicator(),
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
