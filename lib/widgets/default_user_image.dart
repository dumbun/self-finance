// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/widgets/image_widget.dart';

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
    return ImageWidget(
      shape: BoxShape.circle,
      height: height ?? 30.sp,
      width: width ?? 30.sp,
      child: const Svg(
        "assets/icon/defaultImage.svg",
        source: SvgSource.asset,
      ),
    );
  }
}
