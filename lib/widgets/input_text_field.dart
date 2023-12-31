// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:self_finance/theme/colors.dart';

class InputTextField extends StatelessWidget {
  const InputTextField({
    super.key,
    this.controller,
    this.hintText,
    this.fillColor,
    this.onChanged,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController? controller;
  final String? hintText;
  final Color? fillColor;
  final Function? onChanged;
  final String? Function(String?)? validator;

  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged as void Function(String)?,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty || value == "") {
              return 'Please enter a valid value';
            }
            return null;
          },
      keyboardType: keyboardType ?? TextInputType.text,
      textInputAction: TextInputAction.done,
      controller: controller,
      enableSuggestions: true,
      textAlign: TextAlign.start,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: hintText,
        border: const OutlineInputBorder(),
        labelStyle: const TextStyle(
          color: AppColors.getLigthGreyColor,
        ),
      ),
    );
  }
}
