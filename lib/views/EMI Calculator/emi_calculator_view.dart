import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/logic/logic.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/widgets/currency_widget.dart';
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
    const SizedBox sb = SizedBox(height: 20);
    return Padding(
      padding: const EdgeInsetsGeometry.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            sb,
            //taken date
            InputDatePicker(
              controller: _takenDataInput,
              labelText: Constant.takenDate,
              firstDate: _firstDate,
              lastDate: _lastDate,
              initialDate: _initalDate,
            ),
            sb,
            // Tenture Date
            InputDatePicker(
              labelText: Constant.tenureDate,
              controller: _tenureDataInput,
              firstDate: _firstDate,
              initialDate: _initalDate,
              lastDate: _lastDate,
            ),
            sb,

            // taken amount
            InputTextField(
              hintText: Constant.takenAmount,
              keyboardType: TextInputType.number,
              controller: _amountGivenInput,
            ),
            sb,

            // rate of Intrest
            InputTextField(
              hintText: Constant.rateOfIntrest,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              controller: _rateOfIntrestInput,
            ),
            sb,

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
                : const Padding(
                    padding: EdgeInsets.only(top: 20),
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
      final DateFormat format = DateFormat('dd-MM-yyyy');
      setState(() {
        _loanCalculator = LoanCalculator(
          takenAmount: Utility.textToDouble(_amountGivenInput.text),
          rateOfInterest: Utility.textToDouble(_rateOfIntrestInput.text),
          takenDate: format.parseStrict(_takenDataInput.text),
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
      const SizedBox sb = SizedBox(height: 10);
      return Container(
        margin: const EdgeInsets.only(top: 20),
        width: double.infinity,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sb,
            _buildDetailCard(
              currencyType: true,
              icon: Icons.account_balance_wallet,
              label: Constant.takenAmount,
              result: Utility.doubleFormate(principalAmount),
            ),
            sb,
            _buildDetailCard(
              icon: Icons.calendar_month,
              label: 'No.due Dates :',
              result: monthsAndDays,
            ),
            sb,
            _buildDetailCard(
              currencyType: true,
              icon: Icons.percent_rounded,
              label: 'Intrest per Month : ',
              result: Utility.doubleFormate(emiPerMonth),
            ),
            sb,
            _buildDetailCard(
              currencyType: true,
              icon: Icons.addchart_rounded,
              label: 'Total Intrest Amount : ',
              result: Utility.doubleFormate(totalInterest),
            ),
            sb,
            _buildDetailCard(
              currencyType: true,
              icon: Icons.arrow_downward_rounded,
              label: 'Total Amount : ',
              result: Utility.doubleFormate(totalAmount),
            ),
            const SizedBox(height: 32),
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
    bool currencyType = false,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: BodyTwoDefaultText(text: label, bold: true),
        trailing: currencyType
            ? CurrencyWidget(amount: result, smallText: true)
            : BodyTwoDefaultText(text: result, bold: true),
      ),
    );
  }
}
