import 'package:flutter/material.dart';
import 'package:self_finance/core/fonts/body_text.dart';

class DrawerButtonWidget extends StatelessWidget {
  const DrawerButtonWidget({
    super.key,
    required this.onTap,
    required this.text,
    required this.icon,
  });

  final void Function()? onTap;
  final String text;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: ListTile(
          title: BodyOneDefaultText(text: text, bold: true),
          trailing: icon,
        ),
      ),
    );
  }
}
