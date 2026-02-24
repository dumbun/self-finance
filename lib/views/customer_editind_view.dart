import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/utility/image_saving_utility.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';
import 'package:self_finance/widgets/image_widget.dart';

class ContactEditingView extends StatefulWidget {
  const ContactEditingView({super.key, required this.contact});
  final Customer contact;
  @override
  State<ContactEditingView> createState() => _ContactEditingViewState();
}

class _ContactEditingViewState extends State<ContactEditingView> {
  final TextEditingController _customerName = TextEditingController();
  final TextEditingController _gaurdianName = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _mobileNumber = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String imagePath = widget.contact.photo;
  late String proofPath = widget.contact.proof;
  @override
  void initState() {
    imagePath = widget.contact.photo;
    proofPath = widget.contact.proof;
    _customerName.text = widget.contact.name;
    _gaurdianName.text = widget.contact.guardianName;
    _address.text = widget.contact.address;
    _mobileNumber.text = widget.contact.number;
    super.initState();
  }

  @override
  void dispose() {
    _customerName.dispose();
    _gaurdianName.dispose();
    _address.dispose();
    _mobileNumber.dispose();
    super.dispose();
  }

  Column _buildTextFields() {
    return Column(
      children: [
        SizedBox(height: 12.sp),
        InputTextField(
          keyboardType: TextInputType.name,
          controller: _customerName,
          hintText: Constant.customerName,
        ),
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
        SizedBox(height: 20.sp),
        InputTextField(
          keyboardType: TextInputType.name,
          controller: _gaurdianName,
          hintText: Constant.guardianName,
        ),
        SizedBox(height: 20.sp),
        InputTextField(
          keyboardType: TextInputType.streetAddress,
          controller: _address,
          hintText: Constant.customerAddress,
        ),
      ],
    );
  }

  void _navigateToContactsView() {
    Navigator.of(context).pop();
    SnackBarWidget.snackBarWidget(
      context: context,
      message: Constant.contactUpdatedSuccessfully,
    );
  }

  void _showError() {
    AlertDilogs.alertDialogWithOneAction(
      context,
      Constant.error,
      Constant.errorUpdatingContactMessage,
    );
  }

  bool _validateAndSave() {
    final FormState? form = _formKey.currentState;
    if (form!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  Widget _buidImages({
    required String titile,
    required String defaultImages,
    required String imagePath,
    required void Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            elevation: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.sp),
              child: imagePath.isNotEmpty
                  ? ImageWidget(
                      title: titile,
                      imagePath: imagePath,
                      height: 42.sp,
                      width: 42.sp,
                    )
                  : Image.asset(defaultImages, height: 42.sp, width: 42.sp),
            ),
          ),
          BodyTwoDefaultText(text: titile, bold: true),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BodyTwoDefaultText(text: Constant.editContact, bold: true),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(18.sp),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buidImages(
                        onTap: () async {
                          final String newCustomerImage =
                              await ImageSavingUtility.updateCustomerImage(
                                camera: true,
                                customer: widget.contact,
                              );
                          setState(() {
                            imagePath = newCustomerImage;
                          });
                        },
                        defaultImages: Constant.defaultProfileImagePath,
                        imagePath: imagePath,
                        titile: "Customer Image",
                      ),
                      _buidImages(
                        onTap: () async {
                          final String newProofPath =
                              await ImageSavingUtility.updateCustomerProof(
                                camera: true,
                                customer: widget.contact,
                              );
                          setState(() {
                            proofPath = newProofPath;
                          });
                        },
                        defaultImages: Constant.defaultProofImagePath,
                        imagePath: proofPath,
                        titile: "Customer Proof",
                      ),
                    ],
                    // children: [_buildCustomerPhoto(), _buildCustomerProof()],
                  ),
                  SizedBox(height: 20.sp),
                  _buildTextFields(),
                  SizedBox(height: 20.sp),
                  Hero(
                    tag: Constant.saveButtonTag,
                    child: Consumer(
                      builder: (context, ref, child) {
                        return RoundedCornerButton(
                          text: Constant.update,
                          onPressed: () async {
                            if (_validateAndSave()) {
                              final Customer newCustomer = Customer(
                                userID: 1,
                                id: widget.contact.id,
                                name: _customerName.text,
                                guardianName: _gaurdianName.text,
                                address: _address.text,
                                number: _mobileNumber.text,
                                photo: imagePath,
                                proof: proofPath,
                                createdDate: widget.contact.createdDate,
                              );

                              final int response = await ref
                                  .read(
                                    customerProvider(
                                      widget.contact.id!,
                                    ).notifier,
                                  )
                                  .updateCustomer(customer: newCustomer);

                              if (response != 0) {
                                _navigateToContactsView();
                              }
                              if (response == 0) {
                                _showError();
                              }
                            }
                          },
                        );
                      },
                    ),
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
