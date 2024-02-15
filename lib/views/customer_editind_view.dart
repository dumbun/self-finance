import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/providers/customer_contacts_provider.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/utility/util.dart';
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
  final TextEditingController _customerName = TextEditingController();
  final TextEditingController _gaurdianName = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _mobileNumber = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BodyTwoDefaultText(
          text: Constant.editContact,
          bold: true,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(18.sp),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomerPhoto(),
                  SizedBox(height: 20.sp),
                  _buildTextFields(),
                  SizedBox(height: 20.sp),
                  _buildImagePickers(),
                  SizedBox(height: 20.sp),
                  Hero(
                    tag: Constant.saveButtonTag,
                    child: RoundedCornerButton(
                      text: Constant.update,
                      onPressed: _save,
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

  _buildCustomerPhoto() {
    return Center(
      child: SizedBox(
        width: 48.sp,
        height: 48.sp,
        child: Consumer(
          builder: (context, ref, child) {
            final userImageString = ref.watch(updatedCustomerPhotoStringProvider);
            return GestureDetector(
              onTap: () async {
                await Utility.pickImageFromCamera().then(
                  (value) => ref
                      .read(
                        updatedCustomerPhotoStringProvider.notifier,
                      )
                      .update(
                        (state) => value,
                      ),
                );
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Hero(
                    transitionOnUserGestures: true,
                    tag: Constant.customerImageTag,
                    child: userImageString.isEmpty
                        ? DefaultUserImage(
                            height: 46.sp,
                            width: 46.sp,
                          )
                        : SizedBox(
                            height: 46.sp,
                            width: 46.sp,
                            child: Utility.imageFromBase64String(
                              userImageString,
                            ),
                          ),
                  ),
                  Container(
                    padding: EdgeInsets.all(12.sp),
                    decoration: const BoxDecoration(color: AppColors.getPrimaryColor, shape: BoxShape.circle),
                    child: const Icon(Icons.edit_rounded),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _save() async {
    if (_validateAndSave()) {
      final int response = await ref.read(asyncCustomersContactsProvider.notifier).updateCustomer(
            customerId: widget.contact.id!,
            newCustomerName: _customerName.text,
            newGuardianName: _gaurdianName.text,
            newCustomerAddress: _address.text,
            newContactNumber: _mobileNumber.text,
            newCustomerPhoto: ref.read(updatedCustomerPhotoStringProvider),
            newProofPhoto: ref.read(updatedCustomerProofStringProvider),
            newCreatedDate: DateTime.now().toString(),
          );
      if (response != 0) {
        _navigateToContactsView();
      }
      if (response == 0) {
        _showError();
      }
    }
  }

  void _navigateToContactsView() {
    Navigator.of(context).pop();
    // Navigator.of(context).popUntil(ModalRoute.withName('/contactsView/'));
    snackBarWidget(context: context, message: "Contact Updated Successfully ");
  }

  void _showError() {
    AlertDilogs.alertDialogWithOneAction(
      context,
      Constant.error,
      "Error while updating the contact please try again some other time",
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

  Center _buildImagePickers() {
    return _buildCard(
      title: Constant.customerProof,
      updatePhoto: ref.watch(updatedCustomerProofStringProvider),
      onTap: () async {
        try {
          await Utility.pickImageFromCamera().then((value) {
            if (value != "" && value.isNotEmpty) {
              ref.read(updatedCustomerProofStringProvider.notifier).update((state) => value);
            }
          });
        } catch (e) {
          //
        }
      },
      defaultImagePath: Constant.defaultProofImagePath,
      defaultImageWidth: 32.sp,
      defaultImageHeight: 32.sp,
    );
  }

  Center _buildCard({
    required String title,
    required String updatePhoto,
    required void Function()? onTap,
    required String defaultImagePath,
    required double defaultImageHeight,
    required double defaultImageWidth,
  }) {
    return Center(
      child: Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(18.sp),
          child: Consumer(
            builder: (context, ref, child) {
              final photoString = updatePhoto;
              return GestureDetector(
                onTap: onTap,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    photoString.isNotEmpty
                        ? Utility.imageFromBase64String(photoString)
                        : SvgPicture.asset(
                            height: defaultImageHeight,
                            width: defaultImageWidth,
                            defaultImagePath,
                          ),
                    SizedBox(height: 16.sp),
                    BodyTwoDefaultText(
                      text: title,
                      bold: true,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
