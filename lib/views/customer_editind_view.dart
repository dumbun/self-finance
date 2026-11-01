import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/utility/image_saving_utility.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/l10n/app_localizations.dart';
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
  bool _isLoading = false;
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

  Column _buildTextFields(AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: 12),
        InputTextField(
          keyboardType: TextInputType.name,
          controller: _customerName,
          hintText: l10n.customerName,
        ),
        const SizedBox(height: 20),
        InputTextField(
          keyboardType: TextInputType.phone,
          controller: _mobileNumber,
          hintText: l10n.mobileNumber,
          validator: (String? value) {
            if (Utility.isValidPhoneNumber(value)) {
              return null;
            } else {
              return l10n.enterValidNumber;
            }
          },
        ),
        const SizedBox(height: 20),
        InputTextField(
          keyboardType: TextInputType.name,
          controller: _gaurdianName,
          hintText: l10n.guardianName,
        ),
        const SizedBox(height: 20),
        InputTextField(
          keyboardType: TextInputType.streetAddress,
          controller: _address,
          hintText: l10n.customerAddress,
        ),
      ],
    );
  }

  void _navigateToContactsView() {
    Navigator.pop(context);
    SnackBarWidget.snackBarWidget(
      context: context,
      message: context.l10n.contactUpdatedSuccessfully,
    );
  }

  void _showError() {
    AlertDilogs.alertDialogWithOneAction(
      context,
      context.l10n.error,
      context.l10n.errorUpdatingContact,
    );
  }

  bool _validateAndSave() {
    return _formKey.currentState?.validate() ?? false;
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
        children: [
          Card(
            elevation: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imagePath.isNotEmpty
                  ? ImageWidget(
                      title: titile,
                      imagePath: imagePath,
                      height: 72,
                      width: 72,
                    )
                  : Image.asset(defaultImages, height: 72, width: 72),
            ),
          ),
          BodyTwoDefaultText(text: titile, bold: true),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: BodyTwoDefaultText(text: l10n.editContact, bold: true),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buidImages(
                        onTap: () async {
                          final String newCustomerImage =
                              await ImageSavingUtility.updateCustomerImage(
                                camera: true,
                                customer: widget.contact,
                              );
                          if (!mounted) return;
                          setState(() {
                            imagePath = newCustomerImage;
                          });
                        },
                        defaultImages: Constant.defaultProfileImagePath,
                        imagePath: imagePath,
                        titile: l10n.customerPhoto,
                      ),
                      _buidImages(
                        onTap: () async {
                          final String newProofPath =
                              await ImageSavingUtility.updateCustomerProof(
                                camera: true,
                                customer: widget.contact,
                              );
                          if (!mounted) return;
                          setState(() {
                            proofPath = newProofPath;
                          });
                        },
                        defaultImages: Constant.defaultProofImagePath,
                        imagePath: proofPath,
                        titile: l10n.customerProof,
                      ),
                    ],
                    // children: [_buildCustomerPhoto(), _buildCustomerProof()],
                  ),
                  const SizedBox(height: 20),
                  _buildTextFields(l10n),
                  const SizedBox(height: 20),
                  Consumer(
                    builder: (context, ref, child) {
                      return Visibility(
                        visible: _isLoading,
                        replacement: RoundedCornerButton(
                          text: l10n.update,
                          onPressed: () async {
                            if (_isLoading) return;
                            if (_validateAndSave()) {
                              setState(() => _isLoading = true);
                              try {
                                final Customer newCustomer = Customer(
                                  userID: widget.contact.userID,
                                  id: widget.contact.id,
                                  name: _customerName.text.trim(),
                                  guardianName: _gaurdianName.text.trim(),
                                  address: _address.text.trim(),
                                  number: _mobileNumber.text.trim(),
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

                                if (!context.mounted) return;
                                if (response != 0) {
                                  _navigateToContactsView();
                                } else {
                                  _showError();
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                }
                              }
                            }
                          },
                        ),
                        child: const Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      );
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
