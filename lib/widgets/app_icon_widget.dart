import 'package:flutter/material.dart';

class AppIconWidget extends StatelessWidget {
  const AppIconWidget({
    super.key,
    this.alignment = .center,
    this.cacheHeight,
    this.cacheWidth,
    this.fit,
    this.height,
    this.width,
  });
  final AlignmentGeometry alignment;
  final int? cacheHeight;
  final int? cacheWidth;
  final BoxFit? fit;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      alignment: alignment,
      cacheHeight: cacheHeight,
      cacheWidth: cacheWidth,
      fit: fit,
      height: height,
      width: width,
      'assets/icon/icon_only.png',
    );
  }
}
