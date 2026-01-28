// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:self_finance/core/theme/app_colors.dart';

class InputTextField extends StatelessWidget {
  /// [InputTextField] input text field helps to add the text field to user to enter the data

  const InputTextField({
    super.key,
    this.controller,
    this.hintText,
    this.fillColor,
    this.onChanged,
    this.keyboardType,
    this.validator,
    this.initialValue,
  });

  final TextEditingController? controller;
  final String? hintText;
  final Color? fillColor;
  final Function? onChanged;
  final String? Function(String?)? validator;
  final String? initialValue;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged as void Function(String)?,
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty || value == "") {
              return 'Please enter a valid value';
            }
            return null;
          },
      keyboardType: keyboardType,
      textInputAction: TextInputAction.done,
      controller: controller,
      enableSuggestions: true,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        labelText: hintText,
        border: const OutlineInputBorder(),
        labelStyle: const TextStyle(color: AppColors.getLigthGreyColor),
      ),
    );
  }
}
