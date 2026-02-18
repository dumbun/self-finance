// ignore: file_names
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';

class DefaultUserImage extends StatelessWidget {
  const DefaultUserImage({super.key, this.height, this.width, this.cache});

  final double? height;
  final double? width;
  final int? cache;
  @override
  Widget build(BuildContext context) {
    if (cache != null) {
      return Image.asset(
        cacheHeight: cache,
        cacheWidth: cache,
        height: height,
        width: height,
        Constant.defaultProfileImagePath,
      );
    }
    final double size = height ?? 28.sp;
    final int cacheSize = (size * MediaQuery.of(context).devicePixelRatio)
        .round();
    return Image.asset(
      cacheHeight: cacheSize,
      cacheWidth: cacheSize,
      height: height,
      width: height,
      Constant.defaultProfileImagePath,
    );
  }
}
