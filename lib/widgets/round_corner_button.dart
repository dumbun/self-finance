import 'package:flutter/material.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/theme/colors.dart';

class RoundedCornerButton extends StatelessWidget {
  const RoundedCornerButton({super.key, required this.text, required this.onPressed});

  final String text;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: const ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(getPrimaryColor),
      ),
      onPressed: onPressed,
      child: BodyTwoDefaultText(
        text: text,
        color: getBackgroundColor,
        bold: true,
      ),
    );
  }
}
