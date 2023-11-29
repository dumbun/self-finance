import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: "hell",
        fontWeight: FontWeight.bold,
        fontSize: 22.sp,
      ),
    );
  }
}
