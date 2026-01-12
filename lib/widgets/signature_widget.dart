import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class SignatureWidget extends StatefulWidget {
  const SignatureWidget({super.key, required this.signatureGlobalKey});

  final GlobalKey<SfSignaturePadState> signatureGlobalKey;

  @override
  SignatureWidgetState createState() => SignatureWidgetState();
}

class SignatureWidgetState extends State<SignatureWidget> {
  @override
  void initState() {
    super.initState();
  }

  void _handleClearButtonPressed() {
    widget.signatureGlobalKey.currentState!.clear();
  }

  @override
  void dispose() {
    widget.signatureGlobalKey.currentState?.dispose();
    super.dispose();
  }

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
          child: SfSignaturePad(
            key: widget.signatureGlobalKey,
            backgroundColor: Colors.white,
            strokeColor: Colors.black,
            minimumStrokeWidth: 1.0,
            maximumStrokeWidth: 4.0,
          ),
        ),
        SizedBox(height: 10.sp),
        TextButton(
          onPressed: _handleClearButtonPressed,
          child: const Text("Clear"),
        ),
      ],
    );
  }
}
