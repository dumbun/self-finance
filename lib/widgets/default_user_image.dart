import 'package:flutter/material.dart';
import 'package:self_finance/core/constants/constants.dart';

class DefaultUserImage extends StatelessWidget {
  const DefaultUserImage({super.key, this.height, this.width});
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      height: height,
      width: height,
      Constant.defaultProfileImagePath,
    );
  }
}
