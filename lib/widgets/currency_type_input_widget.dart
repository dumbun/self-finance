import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';

class CurrencyTypeInputWidget extends StatefulWidget {
  const CurrencyTypeInputWidget({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<CurrencyTypeInputWidget> createState() =>
      _CurrencyTypeInputWidgetState();
}

class _CurrencyTypeInputWidgetState extends State<CurrencyTypeInputWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showCurrencyPicker(
        theme: CurrencyPickerThemeData(bottomSheetHeight: 90.sp),
        useRootNavigator: true,
        context: context,
        showFlag: true,
        showSearchField: true,
        showCurrencyName: true,
        showCurrencyCode: true,
        onSelect: (Currency currency) {
          setState(() {
            widget.controller.text = currency.symbol;
          });
        },
      ),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(14.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const BodyTwoDefaultText(text: Constant.currencyType, bold: true),
              BodyOneDefaultText(
                text: widget.controller.text,
                bold: true,
                color: AppColors.getPrimaryColor,
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}




/*

TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty || value == "") {
          return 'Please enter a valid value';
        }
        return null;
      },
      onTap: () {
        showCurrencyPicker(
          context: context,
          showFlag: true,
          showSearchField: true,
          showCurrencyName: true,
          showCurrencyCode: true,
          onSelect: (Currency currency) {
            widget.currencyInput.text = ' ${currency.symbol} ${currency.namePlural} ';
          },
        );
      },
      readOnly: true,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      controller: widget.currencyInput,
      enableSuggestions: true,
      textAlign: TextAlign.start,
      autocorrect: false,
      decoration: const InputDecoration(
        labelText: Constant.currencyType,
        border: OutlineInputBorder(),
        labelStyle: TextStyle(
          color: AppColors.getLigthGreyColor,
        ),
      ),
    );

*/