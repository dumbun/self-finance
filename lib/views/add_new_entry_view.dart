import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/backend_provider.dart';
import 'package:self_finance/providers/providers.dart';
import 'package:self_finance/widgets/image_picker_widget.dart';
import 'package:self_finance/widgets/date_picker_widget.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/round_corner_button.dart';

class AddNewEntryView extends ConsumerStatefulWidget {
  const AddNewEntryView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddNewEntryViewState();
}

class _AddNewEntryViewState extends ConsumerState<AddNewEntryView> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final _address = TextEditingController();
  late final _customerName = TextEditingController();
  late final _guardianName = TextEditingController();
  late final _mobileNumber = TextEditingController();
  late final _takenAmount = TextEditingController();
  late final _rateOfInterest = TextEditingController();
  late final _itemName = TextEditingController();
  late final _takenDate = TextEditingController();
  late bool _isloading;

  //animatior

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Adjust the duration as needed
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);

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

  bool validateAndSave() {
    final FormState? form = _formKey.currentState;
    if (form!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    void addNewEntry({
      required String mobileNumber,
      required String address,
      required String customerName,
      required String guardianName,
      required int takenAmount,
      required double rateOfInterest,
      required String itemName,
      required String takenDate,
    }) async {
      try {
        final String photoCustomer = ref.watch(pickedCustomerProfileImageStringProvider);
        final String photoProof = ref.watch(pickedCustomerProofImageStringProvider);
        final String photoItem = ref.watch(pickedCustomerItemImageStringProvider);

        final Customer customer = Customer(
          mobileNumber: mobileNumber,
          address: address,
          customerName: customerName,
          guardianName: guardianName,
          takenDate: takenDate,
          takenAmount: takenAmount,
          rateOfInterest: rateOfInterest,
          itemName: itemName,
          photoCustomer: photoCustomer,
          photoProof: photoProof,
          photoItem: photoItem,
          transaction: 1,
        );

        Transactions transaction = Transactions(
          mobileNumber: mobileNumber,
          address: address,
          customerName: customerName,
          guardianName: guardianName,
          takenDate: takenDate,
          takenAmount: takenAmount,
          rateOfInterest: rateOfInterest,
          itemName: itemName,
          transactionType: 1,
          photoCustomer: photoCustomer,
          photoProof: photoProof,
          photoItem: photoItem,
        );

        bool createNewCustomerEntry = await ref.read(createNewEntryProvider(customer)).when(
          data: (data) {
            if (data) {
              return data;
            } else {
              return false;
            }
          },
          error: (error, stackTrace) {
            return false;
          },
          loading: () {
            return true;
          },
        );

        createNewCustomerEntry = await ref.read(createNewTransactionProvider(transaction)).when(
          data: (data) {
            if (data) {
              return data;
            } else {
              AlertDilogs.alertDialogWithOneAction(
                context,
                "Error",
                'Data is not saved please try again after some time',
              );
              return false;
            }
          },
          error: (error, stackTrace) {
            AlertDilogs.alertDialogWithOneAction(
              context,
              "Error",
              error.toString(),
            );
            return false;
          },
          loading: () {
            return true;
          },
        );

        setState(() {
          _isloading = false;
        });

        alerts() {
          if (createNewCustomerEntry) {
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
          child: Form(
            key: _formKey,
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
                    InputDatePicker(
                      controller: _takenDate,
                      labelText: "Enter Date",
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1950),
                      //DateTime.now() - not to allow to choose before today.
                      lastDate: DateTime(9999),
                    ),
                    SizedBox(height: 24.sp),
                    _buildImagePickers(),
                    SizedBox(height: 24.sp),
                    Visibility(
                      visible: _isloading,
                      replacement: RoundedCornerButton(
                        onPressed: () {
                          if (validateAndSave()) {
                            setState(() {
                              _isloading = true;
                            });

                            double doubleCheck(String text, {String errorString = "error"}) {
                              try {
                                return double.parse(text);
                              } catch (e) {
                                setState(() {
                                  _isloading = false;
                                });
                                return AlertDilogs.alertDialogWithOneAction(context, errorString, e.toString());
                              }
                            }

                            int intCheck(String text, {String errorString = "error"}) {
                              try {
                                return int.parse(text);
                              } catch (e) {
                                setState(() {
                                  _isloading = false;
                                });
                                return AlertDilogs.alertDialogWithOneAction(context, errorString, e.toString());
                              }
                            }

                            addNewEntry(
                              mobileNumber: _mobileNumber.text,
                              address: _address.text,
                              customerName: _customerName.text,
                              guardianName: _guardianName.text,
                              takenAmount: intCheck(_takenAmount.text, errorString: "Taken Amount Error"),
                              rateOfInterest: doubleCheck(_rateOfInterest.text, errorString: "rate Of Interest Error"),
                              itemName: _itemName.text,
                              takenDate: _takenDate.text,
                            );
                            Navigator.of(context).pop();
                          }
                        },
                        text: "Add New Entry",
                      ),
                      child: FadeTransition(opacity: _fadeAnimation, child: const CircularProgressIndicator()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildImagePickers() {
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
