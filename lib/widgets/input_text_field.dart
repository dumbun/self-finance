import 'package:flutter/material.dart';

class InputTextField extends StatelessWidget {
  const InputTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return const TextField(
      controller: controller,
      enableSuggestions: true,
    );
  }
}
