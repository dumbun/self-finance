// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';

class DefaultUserImage extends StatelessWidget {
  const DefaultUserImage({
    super.key,
    this.height,
    this.width,
  });

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      height: height ?? 30.sp,
      width: width ?? 30.sp,
      defaultProfileImagePath,
    );
  }
}
