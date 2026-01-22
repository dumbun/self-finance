// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';

class DefaultUserImage extends StatelessWidget {
  const DefaultUserImage({super.key, this.height, this.width});

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      height: height ?? 28.sp,
      width: width ?? 28.sp,
      Constant.defaultProfileImagePath,
    );
  }
}
