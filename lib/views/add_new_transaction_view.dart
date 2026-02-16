import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/providers/image_providers.dart';
import 'package:self_finance/widgets/signature_widget.dart';
import 'package:self_finance/widgets/image_picker_widget.dart';
import 'package:signature/signature.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/input_date_picker.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

class AddNewTransactionView extends ConsumerStatefulWidget {
  const AddNewTransactionView({super.key, required this.customerID});

  final int customerID;

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
    penColor: Colors.black,
    exportPenColor: Colors.black,
    exportBackgroundColor: Colors.white,
    penStrokeWidth: 5,
  );

  bool _isloading = false;

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
        title: const BodyTwoDefaultText(
          text: Constant.addNewTransaction,
          bold: true,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(18.sp),
              child: Column(
                children: [
                  SizedBox(height: 12.sp),
                  InputTextField(
                    validator: (String? value) =>
                        Utility.amountValidation(value: value),
                    keyboardType: TextInputType.number,
                    hintText: Constant.takenAmount,
                    controller: _amount,
                  ),
                  SizedBox(height: 20.sp),
                  InputTextField(
                    validator: (String? value) =>
                        Utility.amountValidation(value: value),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    hintText: Constant.rateOfIntrest,
                    controller: _rateOfIntrest,
                  ),
                  SizedBox(height: 20.sp),
                  InputDatePicker(
                    controller: _transacrtionDate,
                    firstDate: DateTime(1000),
                    initialDate: DateTime.now(),
                    lastDate: DateTime.now(),
                    labelText: Constant.takenDate,
                  ),
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.multiline,
                    hintText: Constant.itemDescription,
                    controller: _description,
                  ),
                  SizedBox(height: 30.sp),
                  // _buildItemImagePicker(),
                  ImagePickerWidget(
                    imageProvider: itemFileProvider,
                    onSetImage: (file) =>
                        ref.read(itemFileProvider.notifier).set(file),
                    onClearImage: () =>
                        ref.read(itemFileProvider.notifier).clear(),
                    title: Constant.customerItem,
                    defaultImage: Constant.defaultItemImagePath,
                  ),

                  //! Signature Widget that stores signatures on a app data
                  SizedBox(height: 30.sp),
                  SignatureWidget(controller: _signatureController),

                  SizedBox(height: 30.sp),
                  Hero(
                    tag: Constant.saveButtonTag,
                    child: Visibility(
                      visible: _isloading,
                      replacement: RoundedCornerButton(
                        text: Constant.save,
                        onPressed: _save,
                      ),
                      child: const CircularProgressIndicator.adaptive(),
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

  double _doubleCheck(String text, {String errorString = Constant.error}) {
    try {
      return double.parse(text);
    } catch (e) {
      _isloading = false;
      return AlertDilogs.alertDialogWithOneAction(
        context,
        errorString,
        e.toString(),
      );
    }
  }

  void _save() async {
    if (_validateAndSave()) {
      _isloading = true;
      final bool res = await ref
          .read(transactionsProvider.notifier)
          .addNewTransactoion(
            customerId: widget.customerID,
            discription: _description.text,
            pawnedDate: _transacrtionDate.text,
            pawnAmount: _doubleCheck(_amount.text),
            rateOfIntrest: _doubleCheck(_rateOfIntrest.text),
            signatureController: _signatureController,
          );
      res ? _safeSuccuse() : _saveUnSuccessfull();
    }
  }

  void _safeSuccuse() {
    _isloading = false;
    SnackBarWidget.snackBarWidget(
      context: context,
      message: Constant.transacrtionAddedSuccessfully,
    );
    Navigator.of(context).pop();
  }

  void _saveUnSuccessfull() {
    _isloading = false;
    AlertDilogs.alertDialogWithOneAction(
      context,
      Constant.error,
      Constant.errorAddingTransaction,
    );
  }
}
