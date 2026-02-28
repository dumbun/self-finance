import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/widgets/fab.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/input_date_picker.dart';
import 'package:self_finance/widgets/input_text_field.dart';

class CustomerLoneEntryView extends StatefulWidget {
  const CustomerLoneEntryView({
    super.key,
    required this.customerName,
    required this.mobileNumber,
    required this.gaurdianName,
    required this.address,
  });

  final String customerName;
  final String mobileNumber;
  final String gaurdianName;
  final String address;

  @override
  State<CustomerLoneEntryView> createState() => _CustomerLoneEntryViewState();
}

class _CustomerLoneEntryViewState extends State<CustomerLoneEntryView> {
  final TextEditingController _takenDate = TextEditingController();
  final TextEditingController _takenAmount = TextEditingController();
  final TextEditingController _rateOfIntrest = TextEditingController();
  final TextEditingController _itemDescription = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  double _doubleCheck(String text, {String errorString = Constant.error}) {
    try {
      return double.parse(text);
    } catch (e) {
      return AlertDilogs.alertDialogWithOneAction(
        context,
        errorString,
        e.toString(),
      );
    }
  }

  // for validating the form
  bool _validateAndSave() {
    final FormState? form = _formKey.currentState;
    if (form!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _takenDate.dispose();
    _takenAmount.dispose();
    _rateOfIntrest.dispose();
    _itemDescription.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BodySmallText(text: "Lone Amount", bold: true),
      ),
      floatingActionButton: Fab(
        onPressed: () {
          if (_validateAndSave()) {
            Routes.navigateToCustomerConformationView(
              context: context,
              customerName: widget.customerName,
              mobileNumber: widget.mobileNumber,
              gaurdianName: widget.gaurdianName,
              address: widget.address,
              itemDescription: _itemDescription.text,
              rateOfIntrest: _doubleCheck(_rateOfIntrest.text),
              takenAmount: _doubleCheck(_takenAmount.text),
              takenDate: _takenDate.text,
            );
          }
        },
        icon: Icons.save,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.sp),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //taken amount
                SizedBox(height: 20.sp),
                InputTextField(
                  keyboardType: TextInputType.number,
                  hintText: Constant.takenAmount,
                  validator: (String? value) =>
                      Utility.amountValidation(value: value),
                  controller: _takenAmount,
                ),

                // rate of intrest
                SizedBox(height: 20.sp),
                InputTextField(
                  validator: (String? value) =>
                      Utility.amountValidation(value: value),
                  hintText: Constant.rateOfIntrest,
                  controller: _rateOfIntrest,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: false,
                    decimal: true,
                  ),
                ),

                // taken date picker
                SizedBox(height: 20.sp),
                InputDatePicker(
                  controller: _takenDate,
                  labelText: Constant.takenDate,
                  firstDate: DateTime(1000),
                  lastDate: DateTime.now(),
                  initialDate: DateTime.now(),
                ),

                // item description
                SizedBox(height: 20.sp),
                InputTextField(
                  controller: _itemDescription,
                  hintText: Constant.itemDescription,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
