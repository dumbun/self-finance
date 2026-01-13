import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
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
        SizedBox(height: 20.sp),
        Container(
          padding: EdgeInsets.all(18.sp),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: Signature(
            controller: widget.controller,
            backgroundColor: Colors.white,
            width: 300,
            height: 300,
          ),
        ),
        SizedBox(height: 10.sp),
        TextButton(
          onPressed: widget.controller.clear,
          child: const Text("Clear"),
        ),
      ],
    );
  }
}
