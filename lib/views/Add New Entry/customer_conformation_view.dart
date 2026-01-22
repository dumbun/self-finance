import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history_model.dart';
import 'package:self_finance/providers/customer_contacts_provider.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/providers/history_provider.dart';
import 'package:self_finance/providers/items_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/image_saving_utility.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/widgets/currency_widget.dart';
// import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/signature_widget.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';
import 'package:self_finance/widgets/image_picker_widget.dart';
import 'package:signature/signature.dart';

class CustomerConformationView extends ConsumerStatefulWidget {
  final String customerName;
  final String mobileNumber;
  final String gaurdianName;
  final String address;
  final String takenDate;
  final double takenAmount;
  final double rateOfIntrest;
  final String itemDescription;

  const CustomerConformationView({
    super.key,
    required this.customerName,
    required this.mobileNumber,
    required this.gaurdianName,
    required this.address,
    required this.takenDate,
    required this.takenAmount,
    required this.rateOfIntrest,
    required this.itemDescription,
  });

  @override
  ConsumerState<CustomerConformationView> createState() =>
      _CustomerConformationViewState();
}

class _CustomerConformationViewState
    extends ConsumerState<CustomerConformationView> {
  final SignatureController _signatureGlobalKey = SignatureController(
    penColor: Colors.black,
    exportPenColor: Colors.black,
    exportBackgroundColor: Colors.white,
    penStrokeWidth: 5,
  );

  @override
  void dispose() {
    _signatureGlobalKey.dispose();
    super.dispose();
  }

  ListTile _buildListTile({
    required String title,
    required String data,
    bool currency = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.all(4.sp),
      subtitle: currency
          ? Row(
              children: [
                BodyOneDefaultText(bold: true, text: data),
                CurrencyWidget(),
              ],
            )
          : BodyOneDefaultText(bold: true, text: data),
      title: BodySmallText(text: title),
    );
  }

  Column _buildImagePickers() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ImagePickerWidget(
                imageProvier: imageProvider,
                title: Constant.customerPhoto,
                defaultImage: Constant.defaultProfileImagePath,
              ),
            ),
            Expanded(
              child: ImagePickerWidget(
                imageProvier: proofProvider,
                title: Constant.customerProof,
                defaultImage: Constant.defaultProofImagePath,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.sp),
        ImagePickerWidget(
          title: Constant.customerItem,
          defaultImage: Constant.defaultItemImagePath,
          imageProvier: itemProvider,
        ),
      ],
    );
  }

  bool _isloading = false;

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

    SnackBarWidget.snackBarWidget(
      context: context,
      message: Constant.savedSuccessfullyText,
    );
    Routes.navigateToDashboard(context: context);
  }

  void _afterFail() {
    _alertDilog(title: Constant.error, content: Constant.pleaseTryAgain);
    Navigator.pop(context);
  }

  void _containsSameNumberInDB() {
    setState(() {
      _isloading = false;
    });

    _alertDilog(title: "Error", content: Constant.contactAlreadyExistMessage);
  }

  void _save() async {
    setState(() => _isloading = true);

    /// already Existing mobile number present check [error]
    final List<String> customerNumbers = await ref
        .read(asyncCustomersProvider.notifier)
        .fetchAllCustomersNumbers();
    if (customerNumbers.contains(widget.mobileNumber) == false) {
      final String presentDateTime = DateTime.now().toString();
      final takenAmount = widget.takenAmount;

      // saving image to storage
      final String imagePath = await ImageSavingUtility.saveImage(
        location: 'customers',
        image: ref.read(imageProvider),
      );

      final String proofPath = await ImageSavingUtility.saveImage(
        location: 'proofs',
        image: ref.read(proofProvider),
      );

      // creating the new customer

      final int customerCreatedResponse = await ref
          .read(asyncCustomersContactsProvider.notifier)
          .addCustomer(
            customer: Customer(
              userID: 1, //? later updates if there are more users
              name: widget.customerName,
              guardianName: widget.gaurdianName,
              address: widget.address,
              number: widget.mobileNumber,
              photo: imagePath,
              proof: proofPath,
              createdDate: presentDateTime,
            ),
          );
      if (customerCreatedResponse != 0) {
        // Do image save
        // creating new item becacuse every new transaction will have a proof item
        final String itemImagePath = await ImageSavingUtility.saveImage(
          location: 'items',
          image: ref.read(itemProvider),
        );
        final int itemCreatedResponse = await ref
            .read(asyncItemsProvider.notifier)
            .addItem(
              item: Items(
                customerid: customerCreatedResponse,
                name: widget.itemDescription,
                description: widget.itemDescription,
                pawnedDate: widget.takenDate,
                expiryDate: presentDateTime,
                pawnAmount: takenAmount,
                status: Constant.active,
                photo: itemImagePath,
                createdDate: presentDateTime,
              ),
            );
        if (itemCreatedResponse != 0) {
          final String signatureResponse =
              await Utility.saveSignaturesInStorage(
                signatureController: _signatureGlobalKey,
                imageName: itemCreatedResponse.toString(),
              );

          // creating new transaction
          final int transactionCreatedResponse = await ref
              .read(asyncTransactionsProvider.notifier)
              .addTransaction(
                transaction: Trx(
                  customerId: customerCreatedResponse,
                  itemId: itemCreatedResponse,
                  transacrtionDate: widget.takenDate,
                  transacrtionType: Constant.active,
                  amount: takenAmount,
                  intrestRate: widget.rateOfIntrest,
                  intrestAmount:
                      (widget.takenAmount * widget.rateOfIntrest) / 100,
                  remainingAmount: 0,
                  signature: signatureResponse,
                  createdDate: presentDateTime,
                ),
              );
          if (transactionCreatedResponse != 0) {
            // creating history
            final int historyResponse = await ref
                .read(asyncHistoryProvider.notifier)
                .addHistory(
                  history: UserHistory(
                    userID: 1,
                    customerID: customerCreatedResponse,
                    itemID: itemCreatedResponse,
                    customerName: widget.customerName,
                    customerNumber: widget.mobileNumber,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BodySmallText(text: "Customer conformation", bold: true),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.getPrimaryColor,
        onPressed: _save,
        child: Visibility(
          visible: _isloading,
          replacement: Icon(Icons.volunteer_activism),
          child: const Center(child: CircularProgressIndicator.adaptive()),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.sp),
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  _buildImagePickers(),
                  _buildListTile(
                    title: Constant.customerName,
                    data: widget.customerName,
                  ),
                  _buildListTile(
                    title: Constant.guardianName,
                    data: widget.gaurdianName,
                  ),
                  _buildListTile(
                    title: Constant.customerAddress,
                    data: widget.address,
                  ),
                  _buildListTile(
                    title: Constant.mobileNumber,
                    data: widget.mobileNumber,
                  ),
                  _buildListTile(
                    title: Constant.takenDate,
                    data: widget.takenDate,
                  ),
                  _buildListTile(
                    currency: true,
                    title: Constant.takenAmount,
                    data: "${widget.takenAmount} ",
                  ),

                  _buildListTile(
                    title: Constant.rateOfIntrest,
                    data: widget.rateOfIntrest.toString(),
                  ),
                  _buildListTile(
                    title: Constant.itemDescription,
                    data: widget.itemDescription,
                  ),
                  SignatureWidget(controller: _signatureGlobalKey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
