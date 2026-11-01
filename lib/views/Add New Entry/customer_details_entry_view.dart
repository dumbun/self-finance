import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/l10n/app_localizations.dart';
import 'package:self_finance/models/country_model.dart';
import 'package:self_finance/providers/contacts_provider.dart';
import 'package:self_finance/providers/date_provider.dart';
import 'package:self_finance/providers/image_providers.dart';
import 'package:self_finance/widgets/country_code_picker_widget.dart';
import 'package:self_finance/widgets/customer_otp_verification_bottom_sheet.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/drop_down_gardian_selection.dart';
import 'package:self_finance/widgets/image_picker_widget.dart';
import 'package:self_finance/widgets/input_date_picker.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:self_finance/widgets/section_header_widget.dart';
import 'package:self_finance/widgets/signature_widget.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';
import 'package:signature/signature.dart';

class CustomerDetailsEntryView extends ConsumerStatefulWidget {
  const CustomerDetailsEntryView({super.key});

  @override
  ConsumerState<CustomerDetailsEntryView> createState() =>
      _CustomerDetailsEntryViewState();
}

class _CustomerDetailsEntryViewState
    extends ConsumerState<CustomerDetailsEntryView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Customer details controllers
  final TextEditingController _customerName = TextEditingController();
  final TextEditingController _gaurdianAlias = TextEditingController();
  final TextEditingController _gaurdianName = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _mobileNumber = TextEditingController();

  // Loan & transaction controllers
  final TextEditingController _takenAmount = TextEditingController();
  final TextEditingController _rateOfIntrest = TextEditingController();
  final TextEditingController _takenDate = TextEditingController();
  final TextEditingController _itemDescription = TextEditingController();

  // Signature controller
  final SignatureController _signatureController = SignatureController(
    exportPenColor: AppColors.contentColorBlack,
    exportBackgroundColor: AppColors.getBackgroundColor,
    penStrokeWidth: 5,
  );

  // Country code selection
  Country _selectedCountry = Country.defaultCountry;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _takenDate.text = DateFormat('dd-MM-yyyy').format(now);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(imageFileProvider.notifier).clear();
        ref.read(proofFileProvider.notifier).clear();
        ref.read(itemFileProvider.notifier).clear();
        ref.read(dateProvider.notifier).set(now);
      }
    });
  }

  @override
  void dispose() {
    _customerName.dispose();
    _gaurdianAlias.dispose();
    _gaurdianName.dispose();
    _address.dispose();
    _mobileNumber.dispose();
    _takenAmount.dispose();
    _rateOfIntrest.dispose();
    _takenDate.dispose();
    _itemDescription.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  bool _validateAndSave() {
    return _formKey.currentState?.validate() ?? false;
  }

  double? _doubleCheck(String text, {String? errorString}) {
    try {
      return double.parse(text);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AlertDilogs.alertDialogWithOneAction(
          context,
          errorString ?? context.l10n.error,
          e.toString(),
        );
      }
      return null;
    }
  }

  Future<void> _save() async {
    if (_isLoading) return;
    if (!_validateAndSave()) return;

    final double? amount = _doubleCheck(_takenAmount.text.trim());
    final double? rate = _doubleCheck(_rateOfIntrest.text.trim());
    if (amount == null || rate == null) return;

    setState(() => _isLoading = true);

    try {
      final String rawNumber = _mobileNumber.text.trim();
      final String fullNumber = rawNumber.startsWith('+')
          ? rawNumber
          : '${_selectedCountry.dialCode} $rawNumber';
      final String compactNumber = rawNumber.startsWith('+')
          ? rawNumber
          : '${_selectedCountry.dialCode}$rawNumber';

      // Check if number already exists under either formatting
      final bool exists = await Utility.isNumberPresent(fullNumber) ||
          await Utility.isNumberPresent(compactNumber) ||
          await Utility.isNumberPresent(rawNumber);

      if (!mounted) return;

      if (exists) {
        setState(() => _isLoading = false);
        await AlertDilogs.alertDialogWithOneAction(
          context,
          context.l10n.sorry,
          context.l10n.contactAlreadyExistMessage,
        );
        return;
      }

      final String alias = _gaurdianAlias.text.trim();
      final String gName = _gaurdianName.text.trim();
      final String fullGuardian =
          alias.isNotEmpty ? "$alias $gName" : gName;

      // Verify customer OTP before creating loan
      setState(() => _isLoading = false);
      final String? verificationToken = await CustomerOtpVerificationBottomSheet.show(
        context: context,
        customerName: _customerName.text.trim(),
        phoneNumber: fullNumber,
        loanAmount: amount,
      );

      if (!mounted) return;
      if (verificationToken == null) {
        return;
      }

      setState(() => _isLoading = true);

      final bool res = await ref
          .read(contactsProvider.notifier)
          .createNewCustomer(
            customerName: _customerName.text.trim(),
            guardianName: fullGuardian,
            address: _address.text.trim(),
            number: fullNumber,
            discription: _itemDescription.text.trim(),
            takenAmount: amount,
            rateOfIntrest: rate,
            signatureController: _signatureController,
            takenDate: _takenDate.text.trim(),
            verificationToken: verificationToken,
          );

      if (!mounted) return;

      if (res) {
        setState(() => _isLoading = false);
        SnackBarWidget.snackBarWidget(
          context: context,
          message: context.l10n.savedSuccessfully,
        );
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Routes.navigateToDashboard(context: context);
        }
      } else {
        setState(() => _isLoading = false);
        await AlertDilogs.alertDialogWithOneAction(
          context,
          context.l10n.error,
          context.l10n.pleaseTryAgain,
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      await AlertDilogs.alertDialogWithOneAction(
        context,
        context.l10n.error,
        context.l10n.pleaseTryAgain,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BodyTwoDefaultText(
              text: l10n.newCustomerAndLoan,
              bold: true,
            ),
            BodySmallText(
              text: l10n.newCustomerSubtitle,
              color: AppColors.getLigthGreyColor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section 1: Customer Details & Documents
                    SectionHeaderWidget(
                      label: l10n.customerInformation,
                    ),
                    _buildCustomerInformationCard(l10n),
                    const SizedBox(height: 16),

                    // Section 2: Loan Terms & Interest
                    SectionHeaderWidget(
                      label: l10n.loanTermsAndInterest,
                    ),
                    _buildLoanTermsCard(l10n),
                    const SizedBox(height: 16),

                    // Section 3: Collateral Item & Documentation
                    SectionHeaderWidget(
                      label: l10n.collateralAndDocumentation,
                    ),
                    _buildCollateralCard(l10n),
                    const SizedBox(height: 16),

                    // Section 4: Digital Signature
                    SectionHeaderWidget(
                      label: l10n.borrowerAcknowledgement,
                    ),
                    _buildSignatureCard(),
                    const SizedBox(height: 24),

                    // Section 5: Primary Action Button
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    else
                      RoundedCornerButton(
                        text: l10n.createCustomerAndLoan,
                        icon: Icons.check_circle_outline_rounded,
                        onPressed: _save,
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInformationCard(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile & ID Proof Image Pickers
            Row(
              children: [
                Expanded(
                  child: ImagePickerWidget(
                    imageProvider: imageFileProvider,
                    onSetImage: (file) =>
                        ref.read(imageFileProvider.notifier).set(file),
                    onClearImage: () =>
                        ref.read(imageFileProvider.notifier).clear(),
                    title: l10n.customerPhoto,
                    defaultImage: Constant.defaultProfileImagePath,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ImagePickerWidget(
                    imageProvider: proofFileProvider,
                    onSetImage: (file) =>
                        ref.read(proofFileProvider.notifier).set(file),
                    onClearImage: () =>
                        ref.read(proofFileProvider.notifier).clear(),
                    title: l10n.customerProof,
                    defaultImage: Constant.defaultProofImagePath,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Customer Name
            InputTextField(
              hintText: l10n.customerName,
              controller: _customerName,
            ),
            const SizedBox(height: 16),

            // Guardian Selection & Name
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 420) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 130,
                        child: DropDownGardianSelection(
                          controller: _gaurdianAlias,
                          width: 130,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InputTextField(
                          controller: _gaurdianName,
                          hintText: l10n.guardianName,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropDownGardianSelection(
                        controller: _gaurdianAlias,
                      ),
                      const SizedBox(height: 16),
                      InputTextField(
                        controller: _gaurdianName,
                        hintText: l10n.guardianName,
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Country Selector + Phone Number
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CountryCodePickerWidget(
                  selectedCountry: _selectedCountry,
                  onChanged: (country) {
                    setState(() => _selectedCountry = country);
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InputTextField(
                    keyboardType: TextInputType.phone,
                    controller: _mobileNumber,
                    hintText: l10n.mobileNumber,
                    validator: (String? value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) {
                        return l10n.enterValidNumber;
                      }
                      final full = trimmed.startsWith('+')
                          ? trimmed
                          : '${_selectedCountry.dialCode}$trimmed';
                      if (!Utility.isValidPhoneNumber(full) &&
                          !Utility.isValidPhoneNumber(trimmed)) {
                        return l10n.enterValidNumber;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Customer Address
            InputTextField(
              keyboardType: TextInputType.streetAddress,
              controller: _address,
              hintText: l10n.customerAddress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanTermsCard(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 420) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: InputTextField(
                          keyboardType: TextInputType.number,
                          hintText: l10n.takenAmount,
                          validator: (String? value) =>
                              Utility.amountValidation(value: value),
                          controller: _takenAmount,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InputTextField(
                          validator: (String? value) =>
                              Utility.amountValidation(value: value),
                          hintText: l10n.rateOfIntrest,
                          controller: _rateOfIntrest,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InputTextField(
                        keyboardType: TextInputType.number,
                        hintText: l10n.takenAmount,
                        validator: (String? value) =>
                            Utility.amountValidation(value: value),
                        controller: _takenAmount,
                      ),
                      const SizedBox(height: 16),
                      InputTextField(
                        validator: (String? value) =>
                            Utility.amountValidation(value: value),
                        hintText: l10n.rateOfIntrest,
                        controller: _rateOfIntrest,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            InputDatePicker(
              controller: _takenDate,
              labelText: l10n.takenDate,
              firstDate: DateTime(1000),
              lastDate: DateTime.now(),
              initialDate: DateTime.now(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollateralCard(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InputTextField(
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              controller: _itemDescription,
              hintText: l10n.itemDescription,
            ),
            const SizedBox(height: 16),
            ImagePickerWidget(
              imageProvider: itemFileProvider,
              onSetImage: (file) =>
                  ref.read(itemFileProvider.notifier).set(file),
              onClearImage: () =>
                  ref.read(itemFileProvider.notifier).clear(),
              title: l10n.customerItem,
              defaultImage: Constant.defaultItemImagePath,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SignatureWidget(controller: _signatureController),
      ),
    );
  }
}
