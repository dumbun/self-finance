import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/logic/logic.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/views/EMi%20Calculator/emi_calculator_providers.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/title_widget.dart';
import 'package:self_finance/widgets/two_slice_pie_chart_widget.dart';

class EMICalculatorView extends ConsumerWidget {
  EMICalculatorView({super.key});
  final TextEditingController _amountGivenInput = TextEditingController();
  final TextEditingController _rateOfIntrestInput = TextEditingController();
  final DateTime _firstDate = DateTime(1000);
  final DateTime _initalDate = DateTime.now();
  final DateTime _lastDate = DateTime(9999);
  final TextEditingController _takenDataInput = TextEditingController();
  final TextEditingController _tenureDataInput = TextEditingController();

  void _doCalculations(WidgetRef ref) {
    if (_amountGivenInput.text != "" &&
        _rateOfIntrestInput.text != "" &&
        _takenDataInput.text != "" &&
        _tenureDataInput.text != "") {
      double rateOfInterest = textToDouble(_rateOfIntrestInput.text);
      int loneAmount = textToInt(_amountGivenInput.text);
      String takenDate = _takenDataInput.text;
      String tenureDate = _tenureDataInput.text;
      final DateFormat format = DateFormat("dd-MM-yyyy");
      final DateTime convertedDate = format.parseStrict(tenureDate);
      LoanCalculator l1 = LoanCalculator(
        takenAmount: loneAmount,
        rateOfInterest: rateOfInterest,
        takenDate: takenDate,
        tenureDate: convertedDate,
      );
      String monthsAndDays = l1.daysToMonthsAndRemainingDays();
      double intrestPerMonth = l1.getInterestPerDay() * 30;
      double totalInterest = l1.totalInterest();
      int principalAmount = loneAmount;
      double totalAmount = l1.getTotal();
      double firstIndicatorPercentage = (loneAmount / totalAmount) * 100;
      double secoundIndicatorPercentage = (totalInterest / totalAmount) * 100;
      ref.read(monthsAndDaysProvider.notifier).state = monthsAndDays;
      ref.read(emiPerMonthProvider.notifier).state = intrestPerMonth;
      ref.read(principalAmountProvider.notifier).state = principalAmount;
      ref.read(totalAmountProvider.notifier).state = totalAmount;
      ref.read(totalIntrestProvider.notifier).state = totalInterest;
      ref.read(firstIndicatorPercentageProvider.notifier).state = reduceDecimals(firstIndicatorPercentage);
      ref.read(secoundIndicatorPercentageProvider.notifier).state = reduceDecimals(secoundIndicatorPercentage);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalAmount = ref.watch(totalAmountProvider);
    final totalInterest = ref.watch(totalIntrestProvider);
    final emiPerMonth = ref.watch(emiPerMonthProvider);
    final principalAmount = ref.watch(principalAmountProvider);
    final monthsAndDays = ref.watch(monthsAndDaysProvider);
    final double firstIndicatorValue = ref.watch(firstIndicatorPercentageProvider);
    final double secoundIndicatorValue = ref.watch(secoundIndicatorPercentageProvider);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const TitleWidget(text: emiCalculatorTitle),
              SizedBox(height: 20.sp),
              // Taken Date
              _datePicker(
                takenDate,
                _takenDataInput,
                context,
                ref,
              ),
              SizedBox(height: 20.sp),
              // Tenture Date
              _datePicker(
                tenureDate,
                _tenureDataInput,
                context,
                ref,
              ),
              SizedBox(height: 20.sp),
              // taken amount
              InputTextField(
                  hintText: "Taken Amount",
                  keyboardType: TextInputType.number,
                  controller: _amountGivenInput,
                  onChanged: (value) {
                    _doCalculations(ref);
                  }),
              SizedBox(height: 20.sp),
              // rate of Intrest

              InputTextField(
                hintText: "Rate of Intrest %",
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: _rateOfIntrestInput,
                onChanged: (value) {
                  _doCalculations(ref);
                },
              ),
              if (firstIndicatorValue != 0 && secoundIndicatorValue != 0)
                TwoSlicePieChartWidget(
                  firstIndicatorText: "Principal amount",
                  secoundIndicatorText: "Intrest amount",
                  firstIndicatorValue: firstIndicatorValue,
                  secoundIndicatorValue: secoundIndicatorValue,
                ),
              _buildDetails(
                totalAmount,
                totalInterest,
                emiPerMonth,
                principalAmount,
                monthsAndDays,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(
    totalAmount,
    totalInterest,
    emiPerMonth,
    principalAmount,
    monthsAndDays,
  ) {
    if (totalAmount != 0 && totalInterest != 0 && emiPerMonth != 0 && principalAmount != 0 && monthsAndDays != "") {
      return Container(
        margin: EdgeInsets.only(top: 20.sp),
        width: double.infinity,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10.sp),
            BodyOneDefaultText(
              text: 'Principal Amount : ${Utility.numberFormate(principalAmount)}',
              bold: true,
            ),
            SizedBox(height: 10.sp),
            BodyOneDefaultText(
              text: 'No.due Dates : $monthsAndDays',
              bold: true,
            ),
            SizedBox(height: 10.sp),
            BodyOneDefaultText(
              text: 'Intrest per Month : ${reduceDecimals(emiPerMonth)}',
              bold: true,
            ),
            SizedBox(height: 10.sp),
            BodyOneDefaultText(
              text: 'Total Intrest Amount : ${reduceDecimals(totalInterest)}',
              bold: true,
            ),
            SizedBox(height: 10.sp),
            BodyOneDefaultText(
              text: 'Total Amount : ${reduceDecimals(totalAmount)}',
              bold: true,
            ),
            SizedBox(height: 10.sp),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  TextFormField _datePicker(String labelText, TextEditingController controller, BuildContext context, WidgetRef ref) {
    return TextFormField(
      readOnly: true,
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a valid value';
        }
        return null;
      },
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        // icon: const Icon(Icons.calendar_today), //icon of text field
        labelText: labelText, //label text of field
      ),
      textInputAction: TextInputAction.done,
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
          controller.text = formattedDate;
          _doCalculations(ref);
        } else {}
      },
    );
  }
}
