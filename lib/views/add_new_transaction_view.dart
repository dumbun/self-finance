import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history.dart';
import 'package:self_finance/providers/history_provider.dart';
import 'package:self_finance/providers/items_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/input_date_picker.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

///providers
final newItemImageProvider = StateProvider.autoDispose<String>((ref) {
  return "";
});

class AddNewTransactionView extends ConsumerStatefulWidget {
  const AddNewTransactionView({super.key, required this.customerID});

  final int customerID;

  @override
  ConsumerState<AddNewTransactionView> createState() => _AddNewTransactionViewState();
}

class _AddNewTransactionViewState extends ConsumerState<AddNewTransactionView> {
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _rateOfIntrest = TextEditingController();
  final TextEditingController _transacrtionDate = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isloading = false;

  @override
  void dispose() {
    _amount.dispose();
    _rateOfIntrest.dispose();
    _transacrtionDate.dispose();
    _description.dispose();
    super.dispose();
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
                    validator: (value) => Utility.amountValidation(value: value),
                    keyboardType: TextInputType.number,
                    hintText: Constant.takenAmount,
                    controller: _amount,
                  ),
                  SizedBox(height: 20.sp),
                  InputTextField(
                    validator: (value) => Utility.amountValidation(value: value),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  _buldItemImagePicker(),
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

  bool _validateAndSave() {
    final FormState? form = _formKey.currentState;
    if (form!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  double _doubleCheck(String text, {String errorString = Constant.error}) {
    try {
      return double.parse(text);
    } catch (e) {
      _isloading = false;
      return AlertDilogs.alertDialogWithOneAction(context, errorString, e.toString());
    }
  }

  void _save() async {
    if (_validateAndSave()) {
      final List<Customer> customer = await BackEnd.fetchSingleContactDetails(id: widget.customerID);
      final String presentDate = DateTime.now().toString();
      _isloading = true;
      final int itemId = await ref.read(asyncItemsProvider.notifier).addItem(
            item: Items(
              customerid: widget.customerID,
              name: _description.text,
              description: _description.text,
              pawnedDate: _transacrtionDate.text,
              expiryDate: presentDate,
              pawnAmount: _doubleCheck(_amount.text),
              status: Constant.active,
              photo: ref.read(newItemImageProvider),
              createdDate: DateTime.now().toString(),
            ),
          );
      if (itemId != 0) {
        final int transacrtionId = await ref.read(asyncTransactionsProvider.notifier).addTransaction(
              transaction: Trx(
                customerId: widget.customerID,
                itemId: itemId,
                transacrtionDate: _transacrtionDate.text,
                transacrtionType: Constant.active,
                amount: _doubleCheck(_amount.text),
                intrestRate: _doubleCheck(_rateOfIntrest.text),
                intrestAmount: _doubleCheck(_amount.text) * (_doubleCheck(_rateOfIntrest.text) / 100),
                remainingAmount: 0.0,
                createdDate: presentDate,
              ),
            );

        if (transacrtionId != 0) {
          final int historyId = await ref.read(asyncHistoryProvider.notifier).addHistory(
                history: UserHistory(
                  userID: 1,
                  customerID: widget.customerID,
                  customerName: customer.first.name,
                  customerNumber: customer.first.number,
                  itemID: itemId,
                  transactionID: transacrtionId,
                  eventDate: presentDate,
                  eventType: Constant.debited,
                  amount: _doubleCheck(_amount.text),
                ),
              );
          historyId != 0 ? _safeSuccuse() : _saveUnSuccessfull();
        }
      }
    }
  }

  void _safeSuccuse() {
    _isloading = false;
    SnackBarWidget.snackBarWidget(context: context, message: Constant.transacrtionAddedSuccessfully);
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

  Widget _buldItemImagePicker() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(14.sp),
        child: Consumer(
          builder: (context, ref, child) {
            final String newItemImageString = ref.watch(newItemImageProvider);
            return GestureDetector(
              onTap: () async {
                try {
                  await Utility.pickImageFromCamera().then((value) {
                    if (value != "" && value.isNotEmpty) {
                      ref.read(newItemImageProvider.notifier).update((state) => value);
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
                  newItemImageString.isNotEmpty
                      ? Utility.imageFromBase64String(newItemImageString)
                      : SvgPicture.asset(
                          height: 28.sp,
                          width: 28.sp,
                          Constant.defaultItemImagePath,
                        ),
                  SizedBox(height: 12.sp),
                  const BodyOneDefaultText(text: Constant.customerItem),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
