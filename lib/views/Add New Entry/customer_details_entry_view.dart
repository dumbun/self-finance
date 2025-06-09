import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_small_text.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/widgets/fab.dart';
import 'package:self_finance/widgets/input_text_field.dart';

class CustomerDetailsEntryView extends StatefulWidget {
  const CustomerDetailsEntryView({super.key});

  @override
  State<CustomerDetailsEntryView> createState() => _CustomerDetailsEntryViewState();
}

class _CustomerDetailsEntryViewState extends State<CustomerDetailsEntryView> {
  //controllers
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _customerName = TextEditingController();
  final TextEditingController _gaurdianName = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _mobileNumber = TextEditingController();

  @override
  void dispose() {
    _customerName.dispose();
    _mobileNumber.dispose();
    _gaurdianName.dispose();
    _address.dispose();
    super.dispose();
  }

  bool _validateAndSave() {
    final FormState? form = _formKey.currentState;
    if (form!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BodySmallText(
          text: "Customer Details",
          bold: true,
        ),
        forceMaterialTransparency: true,
      ),
      floatingActionButton: Fab(
          icon: Icons.navigate_next_rounded,
          onPressed: () {
            if (_validateAndSave()) {
              Routes.navigateToCustomerLoneEntryView(
                context: context,
                customerName: _customerName.text,
                mobileNumber: _mobileNumber.text,
                gaurdianName: _gaurdianName.text,
                address: _address.text,
              );
            }
          }),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.all(20.sp),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Customer name
                SizedBox(height: 20.sp),
                InputTextField(
                  keyboardType: TextInputType.name,
                  hintText: Constant.customerName,
                  controller: _customerName,
                ),

                // gaurfian Name
                SizedBox(height: 20.sp),
                InputTextField(
                  keyboardType: TextInputType.name,
                  controller: _gaurdianName,
                  hintText: Constant.guardianName,
                ),

                // customer address
                SizedBox(height: 20.sp),
                InputTextField(
                  keyboardType: TextInputType.streetAddress,
                  controller: _address,
                  hintText: Constant.customerAddress,
                ),

                // customer mobile number
                SizedBox(height: 20.sp),
                InputTextField(
                  keyboardType: TextInputType.phone,
                  controller: _mobileNumber,
                  hintText: Constant.mobileNumber,
                  validator: (String? value) {
                    if (Utility.isValidPhoneNumber(value)) {
                      return null;
                    } else {
                      return Constant.enterCorrectNumber;
                    }
                  },
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
