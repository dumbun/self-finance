import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/image_widget.dart';

class CircularImageWidget extends StatelessWidget {
  const CircularImageWidget({
    super.key,
    required this.imageData,
    required this.titile,
    this.customeSize,
    this.cache,
    this.errorBuilder = const SizedBox.shrink(),
  });

  final String imageData;
  final String titile;
  final double? customeSize;
  final int? cache;
  final Widget errorBuilder;

  Widget _buildImage(int cache, double size, BuildContext context) {
    if (imageData.isNotEmpty && File(imageData).existsSync()) {
      return Hero(
        tag: titile,
        child: ClipOval(
          child: ImageWidget(
            errorBuilder: errorBuilder,
            titile: titile,
            imagePath: imageData,
            height: size,
            width: size,
            cache: cache,
          ),
        ),
      );
    }
    return DefaultUserImage(height: size, width: size, cache: cache);
  }

  @override
  Widget build(BuildContext context) {
    final double size = customeSize ?? 44.sp;
    if (cache != null) {
      return _buildImage(cache!, size, context);
    }

    final int cacheSize = (size * MediaQuery.of(context).devicePixelRatio)
        .round();
    return _buildImage(cacheSize, size, context);
  }
}
