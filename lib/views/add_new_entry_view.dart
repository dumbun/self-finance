import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/round_corner_button.dart';

class AddNewEntryView extends StatefulWidget {
  const AddNewEntryView({super.key});

  @override
  State<AddNewEntryView> createState() => _AddNewEntryViewState();
}

class _AddNewEntryViewState extends State<AddNewEntryView> {
  late final _address = TextEditingController();
  late final _customerName = TextEditingController();
  late final _guardianName = TextEditingController();
  late final _mobileNumber = TextEditingController();
  late final _takenAmount = TextEditingController();
  late final _rateOfInterest = TextEditingController();
  late final _itemName = TextEditingController();
  late final _takenDate = TextEditingController();
  late bool _isloading;
  @override
  void initState() {
    _isloading = false;
    super.initState();
  }

  @override
  void dispose() {
    _address.dispose();
    _customerName.dispose();
    _guardianName.dispose();
    _mobileNumber.dispose();
    _takenAmount.dispose();
    _rateOfInterest.dispose();
    _itemName.dispose();
    _takenDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void addNewEntry(
        {required String mobileNumber,
        required String address,
        required String customerName,
        required String guardianName,
        required int takenAmount,
        required double rateOfInterest,
        required String itemName,
        required String takenDate}) async {
      try {
        final bool isCretateNewEntry = await BackEnd.createNewEntry(
          Customer(
            mobileNumber: mobileNumber,
            address: address,
            customerName: customerName,
            guardianName: guardianName,
            takenDate: takenDate,
            takenAmount: takenAmount,
            rateOfInterest: rateOfInterest,
            itemName: itemName,
            transaction: 1,
          ),
        );
        final bool isCreateNewTransaction = await BackEnd.createNewTransaction(
          Transactions(
            mobileNumber: mobileNumber,
            address: address,
            customerName: customerName,
            guardianName: guardianName,
            takenDate: takenDate,
            takenAmount: takenAmount,
            rateOfInterest: rateOfInterest,
            itemName: itemName,
            transactionType: 1,
          ),
        );
        setState(() {
          _isloading = false;
        });

        alerts() {
          if (isCreateNewTransaction && isCretateNewEntry) {
            AlertDilogs.alertDialogWithOneAction(context, "Success", "Data saved ✅ ");
          } else {
            AlertDilogs.alertDialogWithOneAction(context, "Fail", "Data not saved please try again 😥 ");
          }
        }

        alerts();
      } catch (e) {
        // ignore: use_build_context_synchronously
        AlertDilogs.alertDialogWithOneAction(context, "error", e.toString());
      }
    }

    return GestureDetector(
      onVerticalDragDown: (details) => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Add new Entry")),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InputTextField(
                    keyboardType: TextInputType.streetAddress,
                    controller: _address,
                    hintText: "Place",
                  ),
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.name,
                    controller: _customerName,
                    hintText: "Name",
                  ),
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.name,
                    controller: _guardianName,
                    hintText: "Guardian Name",
                  ),
                  SizedBox(height: 20.sp),
                  InputTextField(
                    controller: _mobileNumber,
                    keyboardType: TextInputType.phone,
                    hintText: "Phone Number",
                  ),
                  SizedBox(height: 20.sp),
                  InputTextField(
                    controller: _takenAmount,
                    keyboardType: TextInputType.number,
                    hintText: "Amount",
                  ),
                  SizedBox(height: 20.sp),
                  InputTextField(
                    controller: _rateOfInterest,
                    keyboardType: TextInputType.number,
                    hintText: "Rate of Intrest",
                  ),
                  SizedBox(height: 20.sp),
                  InputTextField(
                    keyboardType: TextInputType.name,
                    controller: _itemName,
                    hintText: "Item Name",
                  ),
                  SizedBox(height: 20.sp),
                  TextFormField(
                    controller: _takenDate,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),

                      icon: Icon(Icons.calendar_today), //icon of text field
                      labelText: "Enter Date", //label text of field
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1950),
                          //DateTime.now() - not to allow to choose before today.
                          lastDate: DateTime.now());
                      if (pickedDate != null) {
                        //pickedDate output format => 2021-03-10 00:00:00.000
                        String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                        //formatted date output using intl package =>  2021-03-16
                        setState(() {
                          _takenDate.text = formattedDate; //set output date to InputTextField value.
                        });
                      } else {}
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_isloading == true) const CircularProgressIndicator(),
                  if (_isloading != true &&
                      _address.text.isNotEmpty &&
                      _customerName.text.isNotEmpty &&
                      _guardianName.text.isNotEmpty &&
                      _itemName.text.isNotEmpty &&
                      _mobileNumber.text.isNotEmpty &&
                      _rateOfInterest.text.isNotEmpty &&
                      _takenAmount.text.isNotEmpty &&
                      _takenDate.text.isNotEmpty)
                    RoundedCornerButton(
                      onPressed: () {
                        setState(() {
                          _isloading = true;
                        });
                        addNewEntry(
                          mobileNumber: _mobileNumber.text,
                          address: _address.text,
                          customerName: _customerName.text,
                          guardianName: _guardianName.text,
                          takenAmount: int.parse(_takenAmount.text),
                          rateOfInterest: double.parse(_rateOfInterest.text),
                          itemName: _itemName.text,
                          takenDate: _takenDate.text,
                        );
                        Navigator.of(context).pop();
                      },
                      text: "Add New Entry",
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
