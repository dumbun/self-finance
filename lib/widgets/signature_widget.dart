import 'package:flutter/material.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:signature/signature.dart';

class SignatureWidget extends StatefulWidget {
  const SignatureWidget({super.key, required this.controller});
  final SignatureController controller;

  @override
  SignatureWidgetState createState() => SignatureWidgetState();
}

class SignatureWidgetState extends State<SignatureWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const BodyTwoDefaultText(
          text: "Customer Signature (Requried) : ",
          bold: true,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: Signature(
            controller: widget.controller,
            backgroundColor: Colors.white,
            width: 300,
            height: 300,
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: widget.controller.clear,
          child: const Text("Clear"),
        ),
      ],
    );
  }
}
