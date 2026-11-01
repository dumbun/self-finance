import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/widgets/fab.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/input_date_picker.dart';
import 'package:self_finance/widgets/input_text_field.dart';

@Deprecated('Use CustomerDetailsEntryView for the unified entry view')
class CustomerLoneEntryView extends StatefulWidget {
  const CustomerLoneEntryView({
    super.key,
    required this.customerName,
    required this.mobileNumber,
    required this.gaurdianName,
    required this.address,
  });

  final String customerName;
  final String mobileNumber;
  final String gaurdianName;
  final String address;

  @override
  State<CustomerLoneEntryView> createState() => _CustomerLoneEntryViewState();
}

class _CustomerLoneEntryViewState extends State<CustomerLoneEntryView> {
  final TextEditingController _takenDate = TextEditingController();
  final TextEditingController _takenAmount = TextEditingController();
  final TextEditingController _rateOfIntrest = TextEditingController();
  final TextEditingController _itemDescription = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _takenDate.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  double? _doubleCheck(String text, {String? errorString}) {
    try {
      return double.parse(text);
    } catch (e) {
      AlertDilogs.alertDialogWithOneAction(
        context,
        errorString ?? context.l10n.error,
        e.toString(),
      );
      return null;
    }
  }

  // for validating the form
  bool _validateAndSave() {
    return _formKey.currentState?.validate() ?? false;
  }

  @override
  void dispose() {
    _takenDate.dispose();
    _takenAmount.dispose();
    _rateOfIntrest.dispose();
    _itemDescription.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BodyTwoDefaultText(text: "Loan Details", bold: true),
      ),
      floatingActionButton: Fab(
        onPressed: () {
          if (_validateAndSave()) {
            final double? rate = _doubleCheck(_rateOfIntrest.text.trim());
            final double? amount = _doubleCheck(_takenAmount.text.trim());
            if (rate == null || amount == null) return;

            Routes.navigateToCustomerConformationView(
              context: context,
              customerName: widget.customerName,
              mobileNumber: widget.mobileNumber,
              gaurdianName: widget.gaurdianName,
              address: widget.address,
              itemDescription: _itemDescription.text.trim(),
              rateOfIntrest: rate,
              takenAmount: amount,
              takenDate: _takenDate.text,
            );
          }
        },
        icon: Icons.navigate_next_rounded,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //taken amount
                  const SizedBox(height: 20),
                  InputTextField(
                    keyboardType: TextInputType.number,
                    hintText: context.l10n.takenAmount,
                    validator: (String? value) =>
                        Utility.amountValidation(value: value),
                    controller: _takenAmount,
                  ),

                  // rate of intrest
                  const SizedBox(height: 20),
                  InputTextField(
                    validator: (String? value) =>
                        Utility.amountValidation(value: value),
                    hintText: context.l10n.rateOfIntrest,
                    controller: _rateOfIntrest,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),

                  // taken date picker
                  const SizedBox(height: 20),
                  InputDatePicker(
                    controller: _takenDate,
                    labelText: context.l10n.takenDate,
                    firstDate: DateTime(1000),
                    lastDate: DateTime.now(),
                    initialDate: DateTime.now(),
                  ),

                  // item description
                  const SizedBox(height: 20),
                  InputTextField(
                    controller: _itemDescription,
                    hintText: context.l10n.itemDescription,
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
