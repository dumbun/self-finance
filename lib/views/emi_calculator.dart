import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/logic/logic.dart';
import 'package:self_finance/theme/colors.dart';
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
  final DateTime _firstDate = presentDate();
  final DateTime _lastDate = DateTime(9999);
  double _firstIndicatorValue = 0;
  double _secoundIndicatorValue = 0;
  int _totalDays = 0;
  double _totalInterest = 0.0;
  int _principalAmount = 0;
  double _emiPerMonth = 0;
  double _totalAmount = 0;
  String _monthsAndDays = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _totalInterest;
    _totalDays;
    _firstIndicatorValue;
    _totalAmount;
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

  _doCalculations() {
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
        _totalAmount = totalAmount;
        _firstIndicatorValue = reduceDecimals(firstIndicatorPercentage);
        _secoundIndicatorValue = reduceDecimals(secoundIndicatorPercentage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              firstDate: _firstDate,
              lastDate: _lastDate,
              initialDate: _firstDate,
              onChanged: ((value) => _doCalculations()),
              labelText: "Taken Date ( dd-MM-yyyy )",
              controller: _takenDataInput,
            ),
            // lone tenure date input widget
            SizedBox(height: 20.sp),
            InputDatePicker(
              firstDate: _firstDate,
              lastDate: _lastDate,
              initialDate: _firstDate,
              onChanged: ((value) => _doCalculations()),
              labelText: "Loan Tenure ( dd-MM-yyyy )",
              controller: _tenureDataInput,
            ),
            SizedBox(height: 20.sp),
            InputTextField(
              onChanged: ((value) => _doCalculations()),
              controller: _amountGivenInput,
              hintText: "Loan Amount",
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20.sp),
            InputTextField(
              onChanged: ((value) => _doCalculations()),
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

            _buildDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails() {
    if (_totalAmount != 0 &&
        _totalInterest != 0 &&
        _emiPerMonth != 0 &&
        _principalAmount != 0 &&
        _monthsAndDays != "") {
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
              text: 'Principal Amount : $_principalAmount',
              bold: true,
            ),
            SizedBox(height: 10.sp),
            BodyOneDefaultText(
              text: 'No.due Dates : $_monthsAndDays',
              bold: true,
            ),
            SizedBox(height: 10.sp),
            BodyOneDefaultText(
              text: 'Intrest per Month : ${reduceDecimals(_emiPerMonth)}',
              bold: true,
            ),
            SizedBox(height: 10.sp),
            BodyOneDefaultText(
              text: 'Total Intrest Amount : ${reduceDecimals(_totalInterest)}',
              bold: true,
            ),
            SizedBox(height: 10.sp),
            BodyOneDefaultText(
              text: 'Total Amount : ${reduceDecimals(_totalAmount)}',
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
}
