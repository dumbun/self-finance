import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/providers/date_provider.dart';
import 'package:self_finance/providers/image_providers.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/widgets/customer_image_widget.dart';
import 'package:self_finance/widgets/customer_otp_verification_bottom_sheet.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/image_picker_widget.dart';
import 'package:self_finance/widgets/input_date_picker.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:self_finance/widgets/section_header_widget.dart';
import 'package:self_finance/widgets/signature_widget.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';
import 'package:signature/signature.dart';

class AddNewTransactionView extends ConsumerStatefulWidget {
  const AddNewTransactionView({
    super.key,
    required this.customerID,
    required this.customerName,
    required this.customerNumber,
  });

  final String customerID;
  final String customerName;
  final String customerNumber;

  @override
  ConsumerState<AddNewTransactionView> createState() =>
      _AddNewTransactionViewState();
}

class _AddNewTransactionViewState extends ConsumerState<AddNewTransactionView> {
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _rateOfIntrest = TextEditingController();
  final TextEditingController _transacrtionDate = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SignatureController _signatureController = SignatureController(
    exportPenColor: AppColors.contentColorBlack,
    exportBackgroundColor: AppColors.getBackgroundColor,
    penStrokeWidth: 5,
  );

  bool _isloading = false;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _transacrtionDate.text = DateFormat('dd-MM-yyyy').format(now);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(dateProvider.notifier).set(now);
      }
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    _rateOfIntrest.dispose();
    _transacrtionDate.dispose();
    _description.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  bool _validateAndSave() {
    return _formKey.currentState?.validate() ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BodyTwoDefaultText(
              text: context.l10n.addNewTransaction,
              bold: true,
            ),
            BodySmallText(
              text: "Customer: ${widget.customerName}",
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
                    // Customer Profile Summary Card
                    SectionHeaderWidget(label: context.l10n.customerInformation),
                    _buildCustomerCard(),
                    const SizedBox(height: 16),

                    // Loan Terms & Amount Card
                    SectionHeaderWidget(label: context.l10n.loanTermsAndInterest),
                    _buildLoanTermsCard(),
                    const SizedBox(height: 16),

                    // Collateral & Documentation Card
                    SectionHeaderWidget(label: context.l10n.collateralAndDocumentation),
                    _buildCollateralCard(),
                    const SizedBox(height: 16),

                    // Digital Signature Card
                    SectionHeaderWidget(label: context.l10n.borrowerAcknowledgement),
                    _buildSignatureCard(),
                    const SizedBox(height: 24),

                    // Primary Action
                    if (_isloading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    else
                      RoundedCornerButton(
                        text: context.l10n.save,
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

  Widget _buildCustomerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CustomerImageWidget(
              customerId: widget.customerID,
              size: 52,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyOneDefaultText(
                    text: widget.customerName,
                    bold: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: AppColors.getLigthGreyColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: BodySmallText(
                          text: widget.customerNumber,
                          color: AppColors.getLigthGreyColor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.getLigthGreyColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: BodySmallText(
                      text: "#${widget.customerID}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      bold: true,
                      color: AppColors.getLigthGreyColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanTermsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InputTextField(
              validator: (String? value) =>
                  Utility.amountValidation(value: value),
              keyboardType: TextInputType.number,
              hintText: context.l10n.takenAmount,
              controller: _amount,
            ),
            const SizedBox(height: 16),
            InputTextField(
              validator: (String? value) =>
                  Utility.amountValidation(value: value),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              hintText: context.l10n.rateOfIntrest,
              controller: _rateOfIntrest,
            ),
            const SizedBox(height: 16),
            InputDatePicker(
              controller: _transacrtionDate,
              firstDate: DateTime(1000),
              initialDate: DateTime.now(),
              lastDate: DateTime.now(),
              labelText: context.l10n.takenDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollateralCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InputTextField(
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              hintText: context.l10n.itemDescription,
              controller: _description,
            ),
            const SizedBox(height: 16),
            ImagePickerWidget(
              imageProvider: itemFileProvider,
              onSetImage: (XFile? file) =>
                  ref.read<ItemFile>(itemFileProvider.notifier).set(file),
              onClearImage: () =>
                  ref.read<ItemFile>(itemFileProvider.notifier).clear(),
              title: context.l10n.customerItem,
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

  double? _doubleCheck(String text, {String? errorString}) {
    try {
      return double.parse(text);
    } catch (e) {
      setState(() => _isloading = false);
      AlertDilogs.alertDialogWithOneAction(
        context,
        errorString ?? context.l10n.error,
        e.toString(),
      );
      return null;
    }
  }

  void _save() async {
    if (_isloading) return;
    if (!_validateAndSave()) return;

    final DateTime? userPickedDate = ref.read(dateProvider);
    if (userPickedDate == null) {
      SnackBarWidget.snackBarWidget(
        context: context,
        message: context.l10n.pleaseSelectTransactionDate,
      );
      return;
    }

    final double? pawnAmount = _doubleCheck(_amount.text.trim());
    final double? rateOfIntrest = _doubleCheck(_rateOfIntrest.text.trim());

    // Bail out if either value failed to parse — dialog was already shown.
    if (pawnAmount == null || rateOfIntrest == null) return;

    // Verify customer OTP before creating transaction
    final String? verificationToken = await CustomerOtpVerificationBottomSheet.show(
      context: context,
      customerName: widget.customerName,
      phoneNumber: widget.customerNumber,
      loanAmount: pawnAmount,
    );

    if (!mounted) return;
    if (verificationToken == null) {
      return;
    }

    setState(() => _isloading = true);
    try {
      final bool res = await ref
          .read(transactionsProvider.notifier)
          .addNewTransactoion(
            customerName: widget.customerName,
            customerNumber: widget.customerNumber,
            customerId: widget.customerID,
            discription: _description.text.trim(),
            userInputDate: userPickedDate,
            pawnAmount: pawnAmount,
            rateOfIntrest: rateOfIntrest,
            signatureController: _signatureController,
            verificationToken: verificationToken,
          );
      if (!mounted) return;
      if (res) {
        ref.read(itemFileProvider.notifier).clear();
        ref.read(dateProvider.notifier).clear();
        _safeSuccuse();
      } else {
        _saveUnSuccessfull();
      }
    } catch (e) {
      if (!mounted) return;
      _saveUnSuccessfull();
    }
  }

  void _safeSuccuse() {
    setState(() => _isloading = false);
    SnackBarWidget.snackBarWidget(
      context: context,
      message: context.l10n.transactionAddedSuccessfully,
    );
    Navigator.pop(context);
  }

  void _saveUnSuccessfull() {
    setState(() => _isloading = false);
    AlertDilogs.alertDialogWithOneAction(
      context,
      context.l10n.error,
      context.l10n.errorAddingTransaction,
    );
  }
}
