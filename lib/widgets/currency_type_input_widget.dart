import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';

class CurrencyTypeInputWidget extends StatelessWidget {
  const CurrencyTypeInputWidget({super.key, required this.controller});
  final TextEditingController controller;

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
        onSelect: (currency) => controller.text = currency.symbol,
      ),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(14.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const BodyTwoDefaultText(text: Constant.currencyType, bold: true),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) => BodyOneDefaultText(
                  text: value.text.isEmpty
                      ? ""
                      : value.text, // optional default
                  bold: true,
                  color: AppColors.getPrimaryColor,
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
