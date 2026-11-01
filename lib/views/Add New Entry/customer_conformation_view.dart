import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/providers/contacts_provider.dart';
import 'package:self_finance/providers/image_providers.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/signature_widget.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';
import 'package:self_finance/widgets/image_picker_widget.dart';
import 'package:signature/signature.dart';

@Deprecated('Use CustomerDetailsEntryView for the unified entry view')
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
      contentPadding: const EdgeInsets.all(4),
      subtitle: currency
          ? CurrencyWidget(amount: data)
          : BodyOneDefaultText(bold: true, text: data.toString()),
      title: BodySmallText(text: title),
    );
  }

  Column _buildImagePickers() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: ImagePickerWidget(
                imageProvider: imageFileProvider,
                onSetImage: (XFile? file) =>
                    ref.read<ImageFile>(imageFileProvider.notifier).set(file),
                onClearImage: () =>
                    ref.read<ImageFile>(imageFileProvider.notifier).clear(),
                title: context.l10n.customerPhoto,
                defaultImage: Constant.defaultProfileImagePath,
              ),
            ),
            Expanded(
              child: ImagePickerWidget(
                imageProvider: proofFileProvider,
                onSetImage: (XFile? file) =>
                    ref.read<ProofFile>(proofFileProvider.notifier).set(file),
                onClearImage: () =>
                    ref.read<ProofFile>(proofFileProvider.notifier).clear(),
                title: context.l10n.customerProof,
                defaultImage: Constant.defaultProofImagePath,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
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
    );
  }

  bool _isloading = false;

  Future<void> _alertDilog({required String title, required String content}) async {
    if (!mounted) return;
    await AlertDilogs.alertDialogWithOneAction(context, title, content);
    if (mounted) {
      setState(() {
        _isloading = false;
      });
    }
  }

  void _afterSuccess() {
    if (mounted) {
      setState(() {
        _isloading = false;
      });
      SnackBarWidget.snackBarWidget(
        context: context,
        message: context.l10n.savedSuccessfully,
      );
      Routes.navigateToDashboard(context: context);
    }
  }

  Future<void> _afterFail() async {
    if (mounted) {
      setState(() => _isloading = false);
      await _alertDilog(
        title: context.l10n.error,
        content: context.l10n.pleaseTryAgain,
      );
    }
  }

  Future<void> _save() async {
    if (_isloading) return;
    setState(() => _isloading = true);

    try {
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
            takenDate: widget.takenDate,
          );
      if (!mounted) return;
      res ? _afterSuccess() : await _afterFail();
    } catch (e) {
      if (!mounted) return;
      await _afterFail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BodyTwoDefaultText(text: "Customer Confirmation", bold: true),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.getPrimaryColor,
        onPressed: _isloading ? null : _save,
        child: Visibility(
          visible: _isloading,
          replacement: const Icon(Icons.volunteer_activism),
          child: const Center(
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  _buildImagePickers(),
                  _buildListTile(
                    title: context.l10n.customerName,
                    data: widget.customerName,
                  ),
                  _buildListTile(
                    title: context.l10n.guardianName,
                    data: widget.gaurdianName,
                  ),
                  _buildListTile(
                    title: context.l10n.customerAddress,
                    data: widget.address,
                  ),
                  _buildListTile(
                    title: context.l10n.mobileNumber,
                    data: widget.mobileNumber,
                  ),
                  _buildListTile(
                    title: context.l10n.takenDate,
                    data: widget.takenDate,
                  ),
                  _buildListTile(
                    currency: true,
                    title: context.l10n.takenAmount,
                    data: Utility.doubleFormate(widget.takenAmount),
                  ),

                  _buildListTile(
                    title: context.l10n.rateOfIntrest,
                    data: "${widget.rateOfIntrest} %",
                  ),
                  _buildListTile(
                    title: context.l10n.itemDescription,
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
