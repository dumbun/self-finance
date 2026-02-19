import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/providers/contacts_provider.dart';
import 'package:self_finance/providers/image_providers.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/widgets/currency_widget.dart';
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
          ? CurrencyWidget(amount: data)
          : BodyOneDefaultText(bold: true, text: data.toString()),
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
                imageProvider: imageFileProvider,
                onSetImage: (file) =>
                    ref.read(imageFileProvider.notifier).set(file),
                onClearImage: () =>
                    ref.read(imageFileProvider.notifier).clear(),
                title: Constant.customerPhoto,
                defaultImage: Constant.defaultProfileImagePath,
              ),
            ),
            Expanded(
              child: ImagePickerWidget(
                imageProvider: proofFileProvider,
                onSetImage: (file) =>
                    ref.read(proofFileProvider.notifier).set(file),
                onClearImage: () =>
                    ref.read(proofFileProvider.notifier).clear(),
                title: Constant.customerProof,
                defaultImage: Constant.defaultProofImagePath,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.sp),
        ImagePickerWidget(
          imageProvider: itemFileProvider,
          onSetImage: (file) => ref.read(itemFileProvider.notifier).set(file),
          onClearImage: () => ref.read(itemFileProvider.notifier).clear(),
          title: Constant.customerItem,
          defaultImage: Constant.defaultItemImagePath,
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

  Future<void> _save() async {
    setState(() => _isloading = true);

    final bool res = await ref
        .read(contactsProvider.notifier)
        .createNewCustomer(
          customerName: widget.customerName,
          guardianName: widget.gaurdianName,
          address: widget.address,
          number: widget.mobileNumber,
          discription: widget.itemDescription,
          takenAmount: widget.takenAmount,
          rateOfIntrest: widget.rateOfIntrest,
          signatureController: _signatureGlobalKey,
        );
    res ? _afterSuccess() : _afterFail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BodySmallText(text: "Customer conformation", bold: true),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.getPrimaryColor,
        onPressed: _save,
        child: Visibility(
          visible: _isloading,
          replacement: const Icon(Icons.volunteer_activism),
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
