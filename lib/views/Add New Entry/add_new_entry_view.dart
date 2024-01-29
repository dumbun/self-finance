import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/providers/items_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/views/Add%20New%20Entry/providers.dart';
import 'package:self_finance/widgets/date_picker_widget.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/image_picker_widget.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

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
        title: const BodyTwoDefaultText(text: "Add new Entry with new Customer"),
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
                    hintText: " Customer Full Name ",
                    controller: _customerName,
                  ),

                  // gaurfian Name
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.name,
                    controller: _gaurdianName,
                    hintText: " Gaurdian Full Name ",
                  ),

                  // customer address
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.streetAddress,
                    controller: _address,
                    hintText: " Customer Address ",
                  ),

                  // customer mobile number
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.phone,
                    controller: _mobileNumber,
                    hintText: " Customer Mobile Number ",
                    validator: (value) {
                      if (Utility.isValidPhoneNumber(value)) {
                        return null;
                      } else {
                        return "please enter correct mobile number ";
                      }
                    },
                  ),

                  //taken amount
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.number,
                    hintText: " Taken amount ",
                    validator: (value) => Utility.amountValidation(value: value),
                    controller: _takenAmount,
                  ),

                  // rate of intrest
                  SizedBox(height: 20.sp),
                  InputTextField(
                    validator: (value) => Utility.amountValidation(value: value),
                    hintText: " Rate of Intrest % ",
                    controller: _rateOfIntrest,
                    keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
                  ),

                  // taken date picker
                  SizedBox(height: 20.sp),
                  InputDatePicker(
                    controller: _takenDate,
                    labelText: " Taken Date dd-MM-yyyy ",
                    firstDate: DateTime(1000),
                    lastDate: DateTime.now(),
                    initialDate: DateTime.now(),
                  ),

                  // item description
                  SizedBox(height: 20.sp),
                  InputTextField(
                    controller: _itemDescription,
                    hintText: " Item Description ",
                  ),

                  // image pickers
                  SizedBox(height: 20.sp),
                  _buildImagePickers(),

                  // save button
                  SizedBox(height: 20.sp),
                  Visibility(
                    visible: _isloading,
                    replacement: RoundedCornerButton(
                      text: " Save + ",
                      onPressed: _save,
                    ),
                    child: const Center(child: CircularProgressIndicator.adaptive()),
                  ),
                  SizedBox(height: 20.sp),
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
      if (customerNumbers.contains(_mobileNumber.text)) {
        _alertDilog(
          title: "",
          content:
              "Contact number is already present in your database please change the number or if you want to add the transacrtion to existing constact please select the add transaction to existing contact in Home Screen",
        );
      } else {
        // creating the new customer
        final Customer newCustomer = Customer(
          name: _customerName.text,
          guardianName: _gaurdianName.text,
          address: _address.text,
          number: _mobileNumber.text,
          photo: ref.read(pickedCustomerProfileImageStringProvider),
          proof: ref.read(pickedCustomerProofImageStringProvider),
          createdDate: DateTime.now().toString(),
        );
        final int customerCreatedResponse =
            await ref.read(asyncCustomersProvider.notifier).addCustomer(customer: newCustomer);

        // creating new item becacuse every new transaction will have a proof item
        final Items newItem = Items(
          customerid: customerCreatedResponse,
          name: _itemDescription.text,
          description: _itemDescription.text,
          pawnedDate: _takenDate.text,
          expiryDate: DateTime.now().toString(),
          pawnAmount: _doubleCheck(_takenAmount.text),
          status: "Active",
          photo: ref.read(pickedCustomerItemImageStringProvider),
          createdDate: DateTime.now().toString(),
        );
        final int itemCreatedResponse = await ref.read(asyncItemsProvider.notifier).addItem(item: newItem);

        // creating new transaction
        final Trx newTransaction = Trx(
          customerId: customerCreatedResponse,
          itemId: itemCreatedResponse,
          transacrtionDate: _takenDate.text,
          transacrtionType: "Debit",
          amount: _doubleCheck(_takenAmount.text),
          intrestRate: _doubleCheck(_rateOfIntrest.text),
          intrestAmount: _doubleCheck(_takenAmount.text) * (_doubleCheck(_rateOfIntrest.text) / 100),
          remainingAmount: 0,
          createdDate: DateTime.now().toString(),
        );
        final int transactionCreatedResponse =
            await ref.read(asyncTransactionsProvider.notifier).addTransaction(transaction: newTransaction);

        // final response
        if (customerCreatedResponse != 0 && itemCreatedResponse != 0 && transactionCreatedResponse != 0) {
          _afterSuccess();
        } else {
          _afterFail();
        }
      }
    }
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
    snackBarWidget(context: context, message: "Saved Successfully 👍");
    Navigator.pop(context);
  }

  void _afterFail() {
    _alertDilog(title: "error", content: "Please Try again");
    Navigator.pop(context);
  }

  double _doubleCheck(String text, {String errorString = "error"}) {
    try {
      return double.parse(text);
    } catch (e) {
      setState(() {
        _isloading = false;
      });
      return AlertDilogs.alertDialogWithOneAction(context, errorString, e.toString());
    }
  }

  int _intCheck(String text, {String errorString = "error"}) {
    try {
      return int.parse(text);
    } catch (e) {
      setState(() {
        _isloading = false;
      });
      return AlertDilogs.alertDialogWithOneAction(context, errorString, e.toString());
    }
  }

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
            ImagePickerWidget(
              text: "Customer Photo",
              defaultImage: defaultProfileImagePath,
              imageProvider: pickedCustomerProfileImageStringProvider,
            ),
            ImagePickerWidget(
              text: "Customer Proof",
              defaultImage: defaultProofImagePath,
              imageProvider: pickedCustomerProofImageStringProvider,
            ),
          ],
        ),
        SizedBox(height: 10.sp),
        ImagePickerWidget(
          text: "Customer Item",
          defaultImage: defaultItemImagePath,
          imageProvider: pickedCustomerItemImageStringProvider,
        ),
      ],
    );
  }
}
