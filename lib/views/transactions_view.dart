import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/widgets/build_transactions_list_widget.dart';
import 'package:self_finance/widgets/transaction_filter_widget.dart';

class TransactionsView extends ConsumerStatefulWidget {
  const TransactionsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionsViewState();
}

class _TransactionsViewState extends ConsumerState<TransactionsView> {
  final TextEditingController _searchTextController = TextEditingController();

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        ref.refresh(transactionsProvider.future).ignore();
        ref.read(filterProvider.notifier).clear();
        ref.read(transactionsDateSearchQueryProvider.notifier).clear();
        ref.read(transactionsSearchQueryProvider.notifier).clear();
      },
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SearchBar(
              controller: _searchTextController,
              padding: WidgetStateProperty.all(
                EdgeInsets.symmetric(horizontal: 12.sp),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(20.sp),
                ),
              ),
              hintStyle: WidgetStatePropertyAll(
                TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              elevation: const WidgetStatePropertyAll(0),
              hintText: "Search transaction ID",
              leading: const Icon(Icons.search),
              onChanged: (String value) =>
                  ref.read(transactionsSearchQueryProvider.notifier).set(value),
              trailing: <Widget>[
                IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      locale: const Locale('en', 'GB'),
                      context: context,
                      initialDate: DateTime.now(),
                      currentDate: DateTime.now(),
                      keyboardType: TextInputType.text,
                      switchToCalendarEntryModeIcon: const Icon(
                        Icons.calendar_month,
                      ),
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
                        _searchTextController.text = formattedDate;
                      });
                      ref
                          .read(transactionsDateSearchQueryProvider.notifier)
                          .set(formattedDate);
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 16.sp),
            const TransactionFilterWidget(),
            SizedBox(height: 16.sp),
            // List Builder
            const Expanded(child: BuildTransactionsListWidget()),
          ],
        ),
      ),
    );
  }
}
