import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/logic/logic.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/widgets/input_date_picker.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/round_corner_button.dart';

class EMICalculatorView extends StatefulWidget {
  const EMICalculatorView({super.key});

  @override
  State<EMICalculatorView> createState() => _EMICalculatorViewState();
}

class _EMICalculatorViewState extends State<EMICalculatorView> {
  final TextEditingController _amountGivenInput = TextEditingController();
  final TextEditingController _rateOfIntrestInput = TextEditingController();
  final TextEditingController _takenDataInput = TextEditingController();
  final TextEditingController _tenureDataInput = TextEditingController();
  final DateTime _firstDate = DateTime(1000);
  final DateTime _initalDate = DateTime.now();
  final DateTime _lastDate = DateTime(9999);
  late LoanCalculator _loanCalculator;

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
    return Padding(
      padding: EdgeInsetsGeometry.all(16.sp),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 16.sp),
            //taken date
            InputDatePicker(
              controller: _takenDataInput,
              labelText: Constant.takenDate,
              firstDate: _firstDate,
              lastDate: _lastDate,
              initialDate: _initalDate,
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
            ),
            SizedBox(height: 20.sp),
            // rate of Intrest
            InputTextField(
              hintText: Constant.rateOfIntrest,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              controller: _rateOfIntrestInput,
            ),
            SizedBox(height: 20.sp),
            RoundedCornerButton(
              onPressed: _doCalculation,
              text: Constant.doCalculation,
            ),
            (_takenDataInput.text.isNotEmpty &&
                    _amountGivenInput.text.isNotEmpty &&
                    _tenureDataInput.text.isNotEmpty &&
                    _rateOfIntrestInput.text.isNotEmpty)
                ? _buildDetails(
                    emiPerMonth: _loanCalculator.interestPerDay * 30,
                    monthsAndDays: _loanCalculator.monthsAndRemainingDays,
                    principalAmount: _loanCalculator.takenAmount,
                    totalAmount: _loanCalculator.totalAmount,
                    totalInterest: _loanCalculator.totalInterestAmount,
                  )
                : Padding(
                    padding: EdgeInsets.only(top: 20.sp),
                    child: BodyTwoDefaultText(
                      error: true,
                      text: Constant.pleaseFillAllFields,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _doCalculation() {
    if (_amountGivenInput.text.isNotEmpty &&
        _rateOfIntrestInput.text.isNotEmpty &&
        _takenDataInput.text.isNotEmpty &&
        _tenureDataInput.text.isNotEmpty) {
      String tenureDate = _tenureDataInput.text;
      final DateFormat format = DateFormat("dd-MM-yyyy");
      setState(() {
        _loanCalculator = LoanCalculator(
          takenAmount: Utility.textToDouble(_amountGivenInput.text),
          rateOfInterest: Utility.textToDouble(_rateOfIntrestInput.text),
          takenDate: _takenDataInput.text,
          tenureDate: format.parseStrict(tenureDate),
        );
      });
    }
  }

  Widget _buildDetails({
    required double totalAmount,
    required double totalInterest,
    required double emiPerMonth,
    required double principalAmount,
    required String monthsAndDays,
  }) {
    if (totalAmount != 0 &&
        totalInterest != 0 &&
        emiPerMonth != 0 &&
        principalAmount != 0 &&
        monthsAndDays != "") {
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
              result: Utility.doubleFormate(principalAmount),
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
            SizedBox(height: 12.sp),
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
      child: ListTile(
        leading: Icon(icon),
        title: BodyTwoDefaultText(text: label, bold: true),
        trailing: BodyTwoDefaultText(text: result, bold: true),
      ),
    );
  }
}
