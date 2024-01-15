import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/views/Add%20New%20Entry/providers.dart';
import 'package:self_finance/widgets/date_picker_widget.dart';
import 'package:self_finance/widgets/image_picker_widget.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/round_corner_button.dart';

class AddNewEntery extends StatefulWidget {
  const AddNewEntery({super.key});

  @override
  State<AddNewEntery> createState() => _AddNewEnteryState();
}

class _AddNewEnteryState extends State<AddNewEntery> {
  final TextEditingController customerName = TextEditingController();
  final TextEditingController takenDate = TextEditingController();
  final TextEditingController gaurdianName = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController mobileNumber = TextEditingController();
  final TextEditingController takenAmount = TextEditingController();
  final TextEditingController rateOfIntrest = TextEditingController();
  final TextEditingController itemDescription = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    customerName.dispose();
    mobileNumber.dispose();
    takenDate.dispose();
    takenAmount.dispose();
    gaurdianName.dispose();
    address.dispose();
    rateOfIntrest.dispose();
    itemDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool validateAndSave() {
      final FormState? form = formKey.currentState;
      if (form!.validate()) {
        return true;
      } else {
        return false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title:
            const BodyTwoDefaultText(text: "Add new Entry with new Customer"),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 16.sp),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.name,
                    hintText: " Customer Name ",
                    controller: customerName,
                  ),
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.name,
                    controller: gaurdianName,
                    hintText: " Gaurdian Name ",
                  ),
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.streetAddress,
                    controller: address,
                    hintText: " Customer Address ",
                  ),
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.phone,
                    controller: mobileNumber,
                    hintText: " Customer Mobile Number ",
                  ),
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.number,
                    hintText: " Taken amount ",
                    controller: takenAmount,
                  ),
                  SizedBox(height: 20.sp),
                  InputTextField(
                    validator: (value) {
                      if (value != null) {
                        if (value.contains(",") ||
                            value.contains(" ") ||
                            value.contains("-")) {
                          return "please enter the correct value";
                        } else {
                          return null;
                        }
                      } else {
                        return null;
                      }
                    },
                    hintText: " Rate of Intrest % ",
                    controller: rateOfIntrest,
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: false, decimal: true),
                  ),
                  SizedBox(height: 20.sp),
                  InputDatePicker(
                    controller: takenDate,
                    labelText: " Taken Date dd-MM-yyy ",
                    firstDate: DateTime(1000),
                    lastDate: DateTime(5000),
                    initialDate: DateTime.now(),
                  ),
                  SizedBox(height: 20.sp),
                  InputTextField(
                    controller: itemDescription,
                    hintText: " Item Description ",
                  ),
                  SizedBox(height: 20.sp),
                  _buildImagePickers(),
                  SizedBox(height: 20.sp),
                  RoundedCornerButton(text: " Save + ", onPressed: () {}),
                  SizedBox(height: 20.sp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
