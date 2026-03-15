import 'package:flutter/material.dart';
import 'package:self_finance/core/theme/app_colors.dart';

class SelectableTextWidget extends StatelessWidget {
  const SelectableTextWidget({super.key, required this.data});
  final String data;

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      data,
      style: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 18,
        fontFamily: "hell",
        color: AppColors.getPrimaryColor,
      ),
    );
  }
}
