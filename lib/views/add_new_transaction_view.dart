import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/items_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/widgets/date_picker_widget.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

///providers
final newItemImageProvider = StateProvider.autoDispose<String>((ref) {
  return "";
});

class AddNewTransactionView extends ConsumerStatefulWidget {
  const AddNewTransactionView({super.key, required this.customer});

  final Customer customer;

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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              transitionOnUserGestures: true,
              tag: "customer-profile-picture",
              child: _buildUserProfilePic(),
            ),
            SizedBox(width: 16.sp),
            BodyOneDefaultText(
              text: widget.customer.name,
              bold: true,
            ),
          ],
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
                    hintText: "Amount",
                    controller: _amount,
                  ),
                  SizedBox(height: 20.sp),
                  InputTextField(
                    validator: (value) => Utility.amountValidation(value: value),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    hintText: "Rate of Intrest",
                    controller: _rateOfIntrest,
                  ),
                  SizedBox(height: 20.sp),
                  InputDatePicker(
                    controller: _transacrtionDate,
                    firstDate: DateTime(1000),
                    initialDate: DateTime.now(),
                    lastDate: DateTime.now(),
                    labelText: "Transaction Date",
                  ),
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.multiline,
                    hintText: "Item Description",
                    controller: _description,
                  ),
                  SizedBox(height: 20.sp),
                  _buldItemImagePicker(),
                  SizedBox(height: 40.sp),
                  Visibility(
                    visible: _isloading,
                    replacement: RoundedCornerButton(text: "Save", onPressed: _save),
                    child: const CircularProgressIndicator.adaptive(),
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

  double _doubleCheck(String text, {String errorString = "error"}) {
    try {
      return double.parse(text);
    } catch (e) {
      _isloading = false;
      return AlertDilogs.alertDialogWithOneAction(context, errorString, e.toString());
    }
  }

  void _save() async {
    if (_validateAndSave()) {
      _isloading = true;
      final int itemId = await ref.read(asyncItemsProvider.notifier).addItem(
            item: Items(
              customerid: widget.customer.id!,
              name: _description.text,
              description: _description.text,
              pawnedDate: _transacrtionDate.text,
              expiryDate: DateTime.now().toString(),
              pawnAmount: _doubleCheck(_amount.text),
              status: "Active",
              photo: ref.read(newItemImageProvider),
              createdDate: DateTime.now().toString(),
            ),
          );
      final int transacrtionId = await ref.read(asyncTransactionsProvider.notifier).addTransaction(
            transaction: Trx(
              customerId: widget.customer.id!,
              itemId: itemId,
              transacrtionDate: _transacrtionDate.text,
              transacrtionType: "Active",
              amount: _doubleCheck(_amount.text),
              intrestRate: _doubleCheck(_rateOfIntrest.text),
              intrestAmount: _doubleCheck(_amount.text) * (_doubleCheck(_rateOfIntrest.text) / 100),
              remainingAmount: 0.0,
              createdDate: DateTime.now().toString(),
            ),
          );

      itemId != 0 && transacrtionId != 0 ? _safeSuccuse() : _saveUnSuccessfull();
    }
  }

  void _safeSuccuse() {
    _isloading = false;
    snackBarWidget(context: context, message: "Transaction added Successfully");
    Navigator.of(context).popUntil(ModalRoute.withName('/contactsView'));
  }

  void _saveUnSuccessfull() {
    _isloading = false;
    AlertDilogs.alertDialogWithOneAction(context, "Error", "Error adding transaction please try agine after some time");
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
                  await pickImageFromCamera().then((value) {
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
                      : const DefaultUserImage(),
                  SizedBox(height: 12.sp),
                  const BodyOneDefaultText(text: "Add Item Imgage"),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserProfilePic() {
    return widget.customer.photo.isEmpty
        ? SizedBox(
            height: 28.sp,
            width: 28.sp,
            child: const DefaultUserImage(),
          )
        : SizedBox(
            height: 28.sp,
            width: 28.sp,
            child: Utility.imageFromBase64String(widget.customer.photo),
          );
  }
}
