// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

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
    this.inputFormatters,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final String? hintText;
  final Color? fillColor;
  final Function? onChanged;
  final String? Function(String?)? validator;
  final String? initialValue;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      inputFormatters: inputFormatters,
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
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: (maxLines != null && maxLines! > 1)
          ? TextInputAction.newline
          : TextInputAction.done,
      controller: controller,
      decoration: InputDecoration(
        labelText: hintText,
        border: const OutlineInputBorder(),
        labelStyle: const TextStyle(color: AppColors.getLigthGreyColor),
      ),
    );
  }
}
