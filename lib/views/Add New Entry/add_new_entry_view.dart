import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/views/Add%20New%20Entry/providers.dart';
import 'package:self_finance/widgets/date_picker_widget.dart';
import 'package:self_finance/widgets/image_picker_widget.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/round_corner_button.dart';

/// [AddNewEntery] is a view
/// which helps the user to save a new customer details with a transcation
class AddNewEntery extends StatefulWidget {
  const AddNewEntery({super.key});

  @override
  State<AddNewEntery> createState() => _AddNewEnteryState();
}

class _AddNewEnteryState extends State<AddNewEntery> {
  final TextEditingController _customerName = TextEditingController();
  final TextEditingController _takenDate = TextEditingController();
  final TextEditingController _gaurdianName = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _mobileNumber = TextEditingController();
  final TextEditingController _takenAmount = TextEditingController();
  final TextEditingController _rateOfIntrest = TextEditingController();
  final TextEditingController _itemDescription = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _customerName.dispose();
    _mobileNumber.dispose();
    _takenDate.dispose();
    _takenAmount.dispose();
    _gaurdianName.dispose();
    _address.dispose();
    _rateOfIntrest.dispose();
    _itemDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const BodyTwoDefaultText(text: "Add new Entry with new Customer"),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 16.sp),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer name
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.name,
                    hintText: " Customer Name ",
                    controller: _customerName,
                  ),

                  // gaurfian Name
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.name,
                    controller: _gaurdianName,
                    hintText: " Gaurdian Name ",
                  ),

                  // customer address
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.streetAddress,
                    controller: _address,
                    hintText: " Customer Address ",
                  ),

                  // customer movile number
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.phone,
                    controller: _mobileNumber,
                    hintText: " Customer Mobile Number ",
                  ),

                  //taken amount
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.number,
                    hintText: " Taken amount ",
                    validator: (value) => _amountValidation(value: value),
                    controller: _takenAmount,
                  ),

                  // rate of intrest
                  SizedBox(height: 20.sp),
                  InputTextField(
                    validator: (value) => _amountValidation(value: value),
                    hintText: " Rate of Intrest % ",
                    controller: _rateOfIntrest,
                    keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
                  ),

                  // taken date picker
                  SizedBox(height: 20.sp),
                  InputDatePicker(
                    controller: _takenDate,
                    labelText: " Taken Date dd-MM-yyy ",
                    firstDate: DateTime(1000),
                    lastDate: DateTime(5000),
                    initialDate: DateTime.now(),
                  ),

                  // item description
                  SizedBox(height: 20.sp),
                  InputTextField(
                    controller: _itemDescription,
                    hintText: " Item Description ",
                  ),

                  // image pickers
                  SizedBox(height: 20.sp),
                  _buildImagePickers(),

                  // save button
                  SizedBox(height: 20.sp),
                  RoundedCornerButton(
                      text: " Save + ",
                      onPressed: () {
                        _validateAndSave();
                      }),
                  SizedBox(height: 20.sp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _amountValidation({required String? value}) {
    if (value == null || value.isEmpty || value == "") {
      return 'Please enter a valid value';
    }
    if (value.contains(",") || value.contains(" ") || value.contains("-")) {
      return "please enter the correct value";
    } else {
      return null;
    }
  }

  bool _validateAndSave() {
    final FormState? form = _formKey.currentState;
    if (form!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  Column _buildImagePickers() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ImagePickerWidget(
              text: "Customer Photo",
              defaultImage: defaultProfileImagePath,
              imageProvider: pickedCustomerProfileImageStringProvider,
            ),
            ImagePickerWidget(
              text: "Customer Proof",
              defaultImage: defaultProofImagePath,
              imageProvider: pickedCustomerProofImageStringProvider,
            ),
          ],
        ),
        SizedBox(height: 10.sp),
        ImagePickerWidget(
          text: "Customer Item",
          defaultImage: defaultItemImagePath,
          imageProvider: pickedCustomerItemImageStringProvider,
        ),
      ],
    );
  }
}
