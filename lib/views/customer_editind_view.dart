import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/providers/customer_contacts_provider.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/views/contact_details_view.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

class ContactEditingView extends ConsumerStatefulWidget {
  const ContactEditingView({super.key, required this.contact});
  final Customer contact;

  @override
  ConsumerState<ContactEditingView> createState() => _ContactEditingViewState();
}

class _ContactEditingViewState extends ConsumerState<ContactEditingView> {
  final TextEditingController customerName = TextEditingController();
  final TextEditingController gaurdianName = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController mobileNumber = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    customerName.text = widget.contact.name;
    gaurdianName.text = widget.contact.guardianName;
    address.text = widget.contact.address;
    mobileNumber.text = widget.contact.number;
    super.initState();
  }

  @override
  void dispose() {
    customerName.dispose();
    gaurdianName.dispose();
    address.dispose();
    mobileNumber.dispose();
    super.dispose();
  }

  _buildTextFields() {
    return Column(
      children: [
        SizedBox(height: 12.sp),
        InputTextField(
          keyboardType: TextInputType.name,
          controller: customerName,
          hintText: "Customer Name",
        ),
        SizedBox(height: 20.sp),
        InputTextField(
          keyboardType: TextInputType.phone,
          controller: mobileNumber,
          hintText: "Contact Number",
          validator: (value) {
            if (Utility.isValidPhoneNumber(value)) {
              return null;
            } else {
              return "please enter correct mobile number ";
            }
          },
        ),
        SizedBox(height: 20.sp),
        InputTextField(
          keyboardType: TextInputType.name,
          controller: gaurdianName,
          hintText: "Guardian Name",
        ),
        SizedBox(height: 20.sp),
        InputTextField(
          keyboardType: TextInputType.streetAddress,
          controller: address,
          hintText: "Address",
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BodyOneDefaultText(text: widget.contact.name),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(18.sp),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFields(),
                  SizedBox(height: 20.sp),
                  _buildImagePickers(),
                  SizedBox(height: 32.sp),
                  RoundedCornerButton(
                    text: "update",
                    onPressed: () async {
                      if (validateAndSave()) {
                        final int response = await ref.read(asyncCustomersContactsProvider.notifier).updateCustomer(
                              customerId: widget.contact.id!,
                              newCustomerName: customerName.text,
                              newGuardianName: gaurdianName.text,
                              newCustomerAddress: address.text,
                              newContactNumber: mobileNumber.text,
                              newCustomerPhoto: ref.read(updatedCustomerPhotoStringProvider),
                              newProofPhoto: ref.read(updatedCustomerProofStringProvider),
                              newCreatedDate: DateTime.now().toString(),
                            );
                        if (response != 0) {
                          navigateToContactsView();
                        }
                        if (response == 0) {
                          showError();
                        }
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

  void navigateToContactsView() {
    Navigator.of(context).popUntil(ModalRoute.withName('/contactsView'));
    snackBarWidget(context: context, message: "Contact Updated Successfully ");
  }

  void showError() {
    AlertDilogs.alertDialogWithOneAction(
      context,
      "Error",
      "Error while updating the contact please try again some other time",
    );
  }

  bool validateAndSave() {
    final FormState? form = formKey.currentState;
    if (form!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  Row _buildImagePickers() {
    // ref.read(updatedCustomerPhotoStringProvider.notifier).state = widget.contact.photo;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Card(
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(14.sp),
            child: Consumer(
              builder: (context, ref, child) {
                final updateCustomerPhoto = ref.watch(updatedCustomerPhotoStringProvider);
                return GestureDetector(
                  onTap: () async {
                    try {
                      await pickImageFromCamera().then((value) {
                        if (value != "" && value.isNotEmpty) {
                          ref.read(updatedCustomerPhotoStringProvider.notifier).update((state) => value);
                        }
                      });
                    } catch (e) {
                      //
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      updateCustomerPhoto.isNotEmpty
                          ? Utility.imageFromBase64String(updateCustomerPhoto)
                          : const DefaultUserImage(),
                      SizedBox(height: 12.sp),
                      const BodyOneDefaultText(text: "Customer Photo"),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        Card(
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(14.sp),
            child: Consumer(
              builder: (context, ref, child) {
                final updateProofPhoto = ref.watch(updatedCustomerProofStringProvider);
                return GestureDetector(
                  onTap: () async {
                    try {
                      await pickImageFromCamera().then((value) {
                        if (value != "" && value.isNotEmpty) {
                          ref.read(updatedCustomerProofStringProvider.notifier).update((state) => value);
                        }
                      });
                    } catch (e) {
                      //
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      updateProofPhoto.isNotEmpty
                          ? Utility.imageFromBase64String(updateProofPhoto)
                          : const DefaultUserImage(),
                      SizedBox(height: 12.sp),
                      const BodyOneDefaultText(text: "Customer Proof"),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
