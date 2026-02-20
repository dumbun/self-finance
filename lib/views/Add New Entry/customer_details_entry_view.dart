import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/drop_down_gardian_selection.dart';
import 'package:self_finance/widgets/fab.dart';
import 'package:self_finance/widgets/input_text_field.dart';

class CustomerDetailsEntryView extends StatefulWidget {
  const CustomerDetailsEntryView({super.key});

  @override
  State<CustomerDetailsEntryView> createState() =>
      _CustomerDetailsEntryViewState();
}

class _CustomerDetailsEntryViewState extends State<CustomerDetailsEntryView> {
  //controllers
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _customerName = TextEditingController();
  final TextEditingController _gaurdianName = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _mobileNumber = TextEditingController();
  final TextEditingController _gaurdianAlias = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    _customerName.dispose();
    _mobileNumber.dispose();
    _gaurdianName.dispose();
    _gaurdianAlias.dispose();
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
        title: const BodySmallText(text: "Customer Details", bold: true),
        forceMaterialTransparency: true,
      ),
      floatingActionButton: Visibility(
        replacement: const CircularProgressIndicator.adaptive(),
        visible: !_isLoading,
        child: Fab(
          icon: Icons.navigate_next_rounded,
          onPressed: () async {
            setState(() {
              _isLoading = !_isLoading;
            });
            if (_validateAndSave()) {
              if (await Utility.isNumberPresent(_mobileNumber.text) &&
                  context.mounted) {
                setState(() {
                  _isLoading = !_isLoading;
                });

                await AlertDilogs.alertDialogWithOneAction(
                  context,
                  "Sorry",
                  Constant.contactAlreadyExistMessage,
                );
                return;
              }
              setState(() {
                _isLoading = !_isLoading;
              });
              Routes.navigateToCustomerLoneEntryView(
                context: context,
                customerName: _customerName.text,
                mobileNumber: _mobileNumber.text,
                gaurdianName: "${_gaurdianAlias.text}  ${_gaurdianName.text}",
                address: _address.text,
              );
            } else {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.sp),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Customer name
                  SizedBox(height: 20.sp),
                  InputTextField(
                    hintText: Constant.customerName,
                    controller: _customerName,
                  ),

                  // gaurfian Name
                  SizedBox(height: 20.sp),
                  DropDownGardianSelection(controller: _gaurdianAlias),
                  SizedBox(height: 20.sp),

                  //Guardian name
                  InputTextField(
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
          ),
        ),
      ),
    );
  }
}
