import 'package:flutter/material.dart';
import 'package:self_finance/theme/colors.dart';

class InputTextField extends StatelessWidget {
  const InputTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.fillColor,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String? hintText;
  final Color? fillColor;

  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a valid value';
        }
        return null;
      },
      keyboardType: keyboardType ?? TextInputType.text,
      controller: controller,
      enableSuggestions: true,
      textAlign: TextAlign.start,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: hintText,
        border: const OutlineInputBorder(),
        fillColor: getVeryLightGreyColor,
      ),
    );
  }
}
