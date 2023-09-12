import 'package:flutter/material.dart';

class RoundedCornerButton extends StatefulWidget {
  const RoundedCornerButton({super.key, required this.text});

  final String text;

  @override
  State<RoundedCornerButton> createState() => _RoundedCornerButtonState();
}

class _RoundedCornerButtonState extends State<RoundedCornerButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () {}, child: Text(widget.text));
  }
}
