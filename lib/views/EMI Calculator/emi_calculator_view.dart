import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/logic/logic.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/views/EMi%20Calculator/emi_calculator_providers.dart';
import 'package:self_finance/widgets/input_date_picker.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/two_slice_pie_chart_widget.dart';

class EMICalculatorView extends ConsumerStatefulWidget {
  const EMICalculatorView({super.key});

  @override
  ConsumerState<EMICalculatorView> createState() => _EMICalculatorViewState();
}

class _EMICalculatorViewState extends ConsumerState<EMICalculatorView> {
  final TextEditingController _amountGivenInput = TextEditingController();
  final TextEditingController _rateOfIntrestInput = TextEditingController();
  final TextEditingController _takenDataInput = TextEditingController();
  final TextEditingController _tenureDataInput = TextEditingController();
  final DateTime _firstDate = DateTime(1000);
  final DateTime _initalDate = DateTime.now();
  final DateTime _lastDate = DateTime(9999);

  @override
  void dispose() {
    _amountGivenInput.dispose();
    _rateOfIntrestInput.dispose();
    _takenDataInput.dispose();
    _tenureDataInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //taken date
            InputDatePicker(
              controller: _takenDataInput,
              labelText: Constant.takenDate,
              firstDate: _firstDate,
              lastDate: _lastDate,
              initialDate: _initalDate,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _initalDate,
                  currentDate: DateTime.now(),
                  keyboardType: TextInputType.datetime,
                  initialDatePickerMode: DatePickerMode.year,
                  firstDate: _firstDate,
                  //DateTime.now() - not to allow to choose before today.
                  lastDate: _lastDate,
                );
                if (pickedDate != null) {
                  //pickedDate output format => 2021-03-10 00:00:00.000
                  String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                  //formatted date output using intl package =>  2021-03-16
                  _takenDataInput.text = formattedDate;
                  _doCalculations(ref);
                } else {}
              },
            ),

            SizedBox(height: 20.sp),
            // Tenture Date
            InputDatePicker(
              labelText: Constant.tenureDate,
              controller: _tenureDataInput,
              firstDate: _firstDate,
              initialDate: _initalDate,
              lastDate: _lastDate,
            ),
            SizedBox(height: 20.sp),
            // taken amount
            InputTextField(
                hintText: Constant.takenAmount,
                keyboardType: TextInputType.number,
                controller: _amountGivenInput,
                onChanged: (value) {
                  _doCalculations(ref);
                }),
            SizedBox(height: 20.sp),
            // rate of Intrest
            InputTextField(
              hintText: Constant.rateOfIntrest,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              controller: _rateOfIntrestInput,
              onChanged: (value) {
                _doCalculations(ref);
              },
            ),
            Consumer(
              builder: (context, ref, child) {
                final totalAmount = ref.watch(totalAmountProvider);
                final totalInterest = ref.watch(totalIntrestProvider);
                final emiPerMonth = ref.watch(emiPerMonthProvider);
                final principalAmount = ref.watch(principalAmountProvider);
                final monthsAndDays = ref.watch(monthsAndDaysProvider);
                final double firstIndicatorValue = ref.watch(firstIndicatorPercentageProvider);
                final double secoundIndicatorValue = ref.watch(secoundIndicatorPercentageProvider);
                return Column(
                  children: [
                    if (firstIndicatorValue != 0 && secoundIndicatorValue != 0)
                      TwoSlicePieChartWidget(
                        firstIndicatorText: Constant.takenAmount,
                        secoundIndicatorText: Constant.intrestAmount,
                        firstIndicatorValue: firstIndicatorValue,
                        secoundIndicatorValue: secoundIndicatorValue,
                      ),
                    _buildDetails(
                      totalAmount: totalAmount,
                      totalInterest: totalInterest,
                      emiPerMonth: emiPerMonth,
                      principalAmount: principalAmount,
                      monthsAndDays: monthsAndDays,
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _doCalculations(WidgetRef ref) {
    if (_amountGivenInput.text.isNotEmpty &&
        _rateOfIntrestInput.text.isNotEmpty &&
        _takenDataInput.text.isNotEmpty &&
        _tenureDataInput.text.isNotEmpty) {
      double rateOfInterest = Utility.textToDouble(_rateOfIntrestInput.text);
      int loneAmount = Utility.textToInt(_amountGivenInput.text);
      String tenureDate = _tenureDataInput.text;
      final DateFormat format = DateFormat("dd-MM-yyyy");
      LoanCalculator l1 = LoanCalculator(
        takenAmount: loneAmount,
        rateOfInterest: rateOfInterest,
        takenDate: _takenDataInput.text,
        tenureDate: format.parseStrict(tenureDate),
      );

      double totalInterest = l1.totalInterestAmount;
      double totalAmount = l1.totalAmount;
      double firstIndicatorPercentage = (loneAmount / totalAmount) * 100;
      double secoundIndicatorPercentage = (totalInterest / totalAmount) * 100;
      ref.read(monthsAndDaysProvider.notifier).state = l1.monthsAndRemainingDays;
      ref.read(emiPerMonthProvider.notifier).state = l1.interestPerDay * 30;
      ref.read(principalAmountProvider.notifier).state = loneAmount;
      ref.read(totalAmountProvider.notifier).state = totalAmount;
      ref.read(totalIntrestProvider.notifier).state = totalInterest;
      ref.read(firstIndicatorPercentageProvider.notifier).state = Utility.reduceDecimals(firstIndicatorPercentage);
      ref.read(secoundIndicatorPercentageProvider.notifier).state = Utility.reduceDecimals(secoundIndicatorPercentage);
    }
  }

  Widget _buildDetails({
    required double totalAmount,
    required double totalInterest,
    required double emiPerMonth,
    required int principalAmount,
    required String monthsAndDays,
  }) {
    if (totalAmount != 0 && totalInterest != 0 && emiPerMonth != 0 && principalAmount != 0 && monthsAndDays != "") {
      return Container(
        margin: EdgeInsets.only(top: 20.sp),
        width: double.infinity,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.sp),
            _buildDetailCard(
              icon: Icons.account_balance_wallet,
              label: Constant.takenAmount,
              result: Utility.numberFormate(principalAmount),
            ),
            SizedBox(height: 10.sp),
            _buildDetailCard(
              icon: Icons.calendar_month,
              label: 'No.due Dates :',
              result: monthsAndDays,
            ),
            SizedBox(height: 10.sp),
            _buildDetailCard(
              icon: Icons.percent_rounded,
              label: 'Intrest per Month : ',
              result: Utility.reduceDecimals(emiPerMonth).toString(),
            ),
            SizedBox(height: 10.sp),
            _buildDetailCard(
              icon: Icons.addchart_rounded,
              label: 'Total Intrest Amount : ',
              result: Utility.reduceDecimals(totalInterest).toString(),
            ),
            SizedBox(height: 10.sp),
            _buildDetailCard(
              icon: Icons.arrow_downward_rounded,
              label: 'Total Amount : ',
              result: Utility.reduceDecimals(totalAmount).toString(),
            ),
            SizedBox(height: 10.sp),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Card _buildDetailCard({
    required IconData icon,
    required String label,
    required String result,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon),
                SizedBox(width: 12.sp),
                BodyTwoDefaultText(
                  text: label,
                  bold: true,
                ),
              ],
            ),
            BodyTwoDefaultText(
              text: result,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}
