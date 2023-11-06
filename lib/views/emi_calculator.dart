import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/logic/logic.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/widgets/date_picker_widget.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/title_widget.dart';
import 'package:self_finance/widgets/two_slice_pie_chart_widget.dart';

class EmiCalculator extends StatefulWidget {
  const EmiCalculator({super.key});

  @override
  State<EmiCalculator> createState() => _EmiCalculatorState();
}

class _EmiCalculatorState extends State<EmiCalculator> {
  final TextEditingController _amountGivenInput = TextEditingController();
  final TextEditingController _rateOfIntrestInput = TextEditingController();
  final TextEditingController _takenDataInput = TextEditingController();
  final TextEditingController _tenureDataInput = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _totalInterest;
    _totalDays;
    _firstIndicatorValue;
    _secoundIndicatorValue;
    _principalAmount;
    _emiPerMonth;
    _monthsAndDays;
    _amountGivenInput.dispose();
    _rateOfIntrestInput.dispose();
    _takenDataInput.dispose();
    _tenureDataInput.dispose();
    super.dispose();
  }

  double _firstIndicatorValue = 0;
  double _secoundIndicatorValue = 0;
  int _totalDays = 0;
  double _totalInterest = 0.0;
  int _principalAmount = 0;
  double _emiPerMonth = 0;
  String _monthsAndDays = "";

  @override
  Widget build(BuildContext context) {
    doCalculations() {
      if (_amountGivenInput.text != "" &&
          _rateOfIntrestInput.text != "" &&
          _takenDataInput.text != "" &&
          _tenureDataInput.text != "") {
        int rateOfInterest = textToInt(_rateOfIntrestInput.text);
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
        int totalDays = l1.getDays();
        String monthsAndDays = l1.daysToMonthsAndRemainingDays();
        double intrestPerMonth = l1.getInterestPerDay() * 30;
        double totalInterest = l1.totalInterest();
        int principalAmount = loneAmount;
        double totalAmount = l1.getTotal();

        double firstIndicatorPercentage = (loneAmount / totalAmount) * 100;
        double secoundIndicatorPercentage = (totalInterest / totalAmount) * 100;
        setState(() {
          _monthsAndDays = monthsAndDays;
          _emiPerMonth = intrestPerMonth;
          _principalAmount = principalAmount;
          _totalInterest = totalInterest;
          _totalDays = totalDays;
          _firstIndicatorValue = reduceDecimals(firstIndicatorPercentage);
          _secoundIndicatorValue = reduceDecimals(secoundIndicatorPercentage);
        });
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.sp),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TitleWidget(text: emiCalculator),
            // taken date input widget
            SizedBox(height: 20.sp),
            InputDatePicker(
              onChanged: ((value) => doCalculations()),
              labelText: "Taken Date ( dd-MM-yyyy )",
              controller: _takenDataInput,
            ),
            // lone tenure date input widget
            SizedBox(height: 20.sp),
            InputDatePicker(
              onChanged: ((value) => doCalculations()),
              labelText: "Loan Tenure ( dd-MM-yyyy )",
              controller: _tenureDataInput,
            ),
            SizedBox(height: 20.sp),
            InputTextField(
              onChanged: ((value) => doCalculations()),
              controller: _amountGivenInput,
              hintText: "Loan Amount",
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20.sp),
            InputTextField(
              onChanged: ((value) => doCalculations()),
              keyboardType: TextInputType.number,
              controller: _rateOfIntrestInput,
              hintText: "Rate of Intrest %",
            ),
            if (_firstIndicatorValue != 0 && _secoundIndicatorValue != 0)
              TwoSlicePieChartWidget(
                firstIndicatorText: "Principal amount",
                secoundIndicatorText: "Intrest amount",
                firstIndicatorValue: _firstIndicatorValue,
                secoundIndicatorValue: _secoundIndicatorValue,
              ),
          ],
        ),
      ),
    );
  }
}
