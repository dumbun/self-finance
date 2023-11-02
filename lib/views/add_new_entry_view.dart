import 'package:flutter/material.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/widgets/input_text_field.dart';

class AddNewEntryView extends StatelessWidget {
  const AddNewEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackgroundColor,
      appBar: AppBar(
        backgroundColor: getBackgroundColor,
        title: const Text(
          "add new entry",
          style: TextStyle(
            fontFamily: "hell",
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [InputTextField()],
        ),
      ),
    );
  }
}
