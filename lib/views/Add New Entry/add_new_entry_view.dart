import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history.dart';
import 'package:self_finance/providers/customer_contacts_provider.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/providers/history_provider.dart';
import 'package:self_finance/providers/items_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/views/Add%20New%20Entry/providers.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/image_picker_widget.dart';
import 'package:self_finance/widgets/input_date_picker.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:self_finance/widgets/signature_widget.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

/// [AddNewEntery] is a view
/// which helps the user to save a new customer details with a transcation
class AddNewEntery extends ConsumerStatefulWidget {
  const AddNewEntery({super.key});

  @override
  ConsumerState<AddNewEntery> createState() => _AddNewEnteryState();
}

class _AddNewEnteryState extends ConsumerState<AddNewEntery> {
  final TextEditingController _customerName = TextEditingController();
  final TextEditingController _takenDate = TextEditingController();
  final TextEditingController _gaurdianName = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _mobileNumber = TextEditingController();
  final TextEditingController _takenAmount = TextEditingController();
  final TextEditingController _rateOfIntrest = TextEditingController();
  final TextEditingController _itemDescription = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<SfSignaturePadState> _signatureGlobalKey = GlobalKey();
  bool _isloading = false;

  @override
  void dispose() {
    _customerName.dispose();
    _mobileNumber.dispose();
    _takenDate.dispose();
    _takenAmount.dispose();
    _gaurdianName.dispose();
    _address.dispose();
    _rateOfIntrest.dispose();
    _itemDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 0,
        title: const BodyOneDefaultText(
          text: Constant.addNewCustomerToolTip,
          bold: true,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 16.sp),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer name
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.name,
                    hintText: Constant.customerName,
                    controller: _customerName,
                  ),

                  // gaurfian Name
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.name,
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

                  //taken amount
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.number,
                    hintText: Constant.takenAmount,
                    validator: (String? value) => Utility.amountValidation(value: value),
                    controller: _takenAmount,
                  ),

                  // rate of intrest
                  SizedBox(height: 20.sp),
                  InputTextField(
                    validator: (String? value) => Utility.amountValidation(value: value),
                    hintText: Constant.rateOfIntrest,
                    controller: _rateOfIntrest,
                    keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
                  ),

                  // taken date picker
                  SizedBox(height: 20.sp),
                  InputDatePicker(
                    controller: _takenDate,
                    labelText: Constant.takenDate,
                    firstDate: DateTime(1000),
                    lastDate: DateTime.now(),
                    initialDate: DateTime.now(),
                  ),

                  // item description
                  SizedBox(height: 20.sp),
                  InputTextField(
                    controller: _itemDescription,
                    hintText: Constant.itemDescription,
                  ),

                  // image pickers
                  SizedBox(height: 20.sp),
                  _buildImagePickers(),

                  // Signature
                  SizedBox(height: 20.sp),
                  const BodyTwoDefaultText(
                    text: "Customer Signature (optional) : ",
                    bold: true,
                  ),
                  SizedBox(height: 20.sp),
                  SignatureWidget(
                    signatureGlobalKey: _signatureGlobalKey,
                  ),

                  // save button
                  SizedBox(height: 20.sp),
                  Visibility(
                    visible: _isloading,
                    replacement: RoundedCornerButton(
                      text: Constant.save,
                      onPressed: _save,
                    ),
                    child: const Center(child: CircularProgressIndicator.adaptive()),
                  ),
                  SizedBox(height: 30.sp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _save() async {
    if (_validateAndSave()) {
      setState(() => _isloading = true);

      /// already Existing mobile number present check [error]
      final List<String> customerNumbers = await ref.read(asyncCustomersProvider.notifier).fetchAllCustomersNumbers();
      if (customerNumbers.contains(_mobileNumber.text) == false) {
        final String presentDateTime = DateTime.now().toString();
        final takenAmount = _doubleCheck(_takenAmount.text);

        // creating the new customer
        final int customerCreatedResponse = await ref.read(asyncCustomersContactsProvider.notifier).addCustomer(
              customer: Customer(
                userID: 1, //? later updates if there are more users
                name: _customerName.text,
                guardianName: _gaurdianName.text,
                address: _address.text,
                number: _mobileNumber.text,
                photo: ref.read(pickedCustomerProfileImageStringProvider),
                proof: ref.read(pickedCustomerProofImageStringProvider),
                createdDate: presentDateTime,
              ),
            );
        if (customerCreatedResponse != 0) {
          // creating new item becacuse every new transaction will have a proof item
          final int itemCreatedResponse = await ref.read(asyncItemsProvider.notifier).addItem(
                  item: Items(
                customerid: customerCreatedResponse,
                name: _itemDescription.text,
                description: _itemDescription.text,
                pawnedDate: _takenDate.text,
                expiryDate: presentDateTime,
                pawnAmount: takenAmount,
                status: Constant.active,
                photo: ref.read(pickedCustomerItemImageStringProvider),
                createdDate: presentDateTime,
              ));
          if (itemCreatedResponse != 0) {
            // creating new transaction
            final int transactionCreatedResponse = await ref.read(asyncTransactionsProvider.notifier).addTransaction(
                    transaction: Trx(
                  customerId: customerCreatedResponse,
                  itemId: itemCreatedResponse,
                  transacrtionDate: _takenDate.text,
                  transacrtionType: Constant.active,
                  amount: takenAmount,
                  intrestRate: _doubleCheck(_rateOfIntrest.text),
                  intrestAmount: _doubleCheck(_takenAmount.text) * (_doubleCheck(_rateOfIntrest.text) / 100),
                  remainingAmount: 0,
                  createdDate: presentDateTime,
                ));
            if (transactionCreatedResponse != 0) {
              //saving signature to the storage

              Utility.saveSignaturesInStorage(
                signatureGlobalKey: _signatureGlobalKey,
                imageName: transactionCreatedResponse.toString(),
              );

              // creating history
              final int historyResponse = await ref.read(asyncHistoryProvider.notifier).addHistory(
                    history: UserHistory(
                      userID: 1,
                      customerID: customerCreatedResponse,
                      itemID: itemCreatedResponse,
                      customerName: _customerName.text,
                      customerNumber: _mobileNumber.text,
                      transactionID: transactionCreatedResponse,
                      eventDate: presentDateTime,
                      eventType: Constant.debited,
                      amount: takenAmount,
                    ),
                  );
              // final response
              (customerCreatedResponse != 0 &&
                      itemCreatedResponse != 0 &&
                      transactionCreatedResponse != 0 &&
                      historyResponse != 0)
                  ? _afterSuccess()
                  : _afterFail();
            }
          }
        }
      } else {
        _containsSameNumberInDB();
      }
    }
  }

  void _containsSameNumberInDB() {
    setState(() {
      _isloading = false;
    });
    _mobileNumber.clear();
    _alertDilog(
      title: "",
      content: Constant.contactAlreadyExistMessage,
    );
  }

  void _alertDilog({required String title, required String content}) {
    AlertDilogs.alertDialogWithOneAction(context, title, content);
    setState(() {
      _isloading = false;
    });
  }

  void _afterSuccess() {
    setState(() {
      _isloading = false;
    });

    SnackBarWidget.snackBarWidget(context: context, message: Constant.savedSuccessfullyText);
    Navigator.pop(context);
  }

  void _afterFail() {
    _alertDilog(title: Constant.error, content: Constant.pleaseTryAgain);
    Navigator.pop(context);
  }

  double _doubleCheck(String text, {String errorString = Constant.error}) {
    try {
      return double.parse(text);
    } catch (e) {
      setState(() {
        _isloading = false;
      });
      return AlertDilogs.alertDialogWithOneAction(context, errorString, e.toString());
    }
  }

  // int _intCheck(String text, {String errorString = Constant.error}) {
  //   try {
  //     return int.parse(text);
  //   } catch (e) {
  //     setState(() {
  //       _isloading = false;
  //     });
  //     return AlertDilogs.alertDialogWithOneAction(context, errorString, e.toString());
  //   }
  // }

  bool _validateAndSave() {
    final FormState? form = _formKey.currentState;
    if (form!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  Column _buildImagePickers() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ImagePickerWidget(
                text: Constant.customerPhoto,
                defaultImage: Constant.defaultProfileImagePath,
                imageProvider: pickedCustomerProfileImageStringProvider,
              ),
            ),
            Expanded(
              child: ImagePickerWidget(
                text: Constant.customerProof,
                defaultImage: Constant.defaultProofImagePath,
                imageProvider: pickedCustomerProofImageStringProvider,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.sp),
        ImagePickerWidget(
          text: Constant.customerItem,
          defaultImage: Constant.defaultItemImagePath,
          imageProvider: pickedCustomerItemImageStringProvider,
        ),
      ],
    );
  }
}
