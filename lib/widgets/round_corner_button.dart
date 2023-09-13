import 'package:flutter/material.dart';
import 'package:self_finance/fonts/bodyTwoDefaultText.dart';
import 'package:self_finance/theme/colors.dart';

class RoundedCornerButton extends StatelessWidget {
  const RoundedCornerButton({super.key, required this.text, required this.onPressed});

  final String text;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: BodyTwoDefaultText(
        text: text,
        color: getBackgroundColor,
        bold: true,
      ),
    );
  }
}
