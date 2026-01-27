import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/widgets/default_user_image.dart';

class CircularImageWidget extends StatelessWidget {
  const CircularImageWidget({
    super.key,
    required this.imageData,
    required this.titile,
  });

  final String imageData;
  final String titile;

  @override
  Widget build(BuildContext context) {
    final File file = File(imageData);
    final double size = 44.sp;
    final int cacheSize = (size * MediaQuery.of(context).devicePixelRatio)
        .round();

    if (imageData.isNotEmpty && file.existsSync()) {
      final Image imageWidget = Image.file(
        file,
        height: size,
        width: size,
        cacheWidth: cacheSize,
        cacheHeight: cacheSize,
        fit: BoxFit.cover,
      );

      return GestureDetector(
        onTap: () {
          Routes.navigateToImageView(
            context: context,
            titile: titile,
            imageWidget: Image.file(file, fit: BoxFit.contain),
          );
        },
        child: Hero(
          tag: titile,
          child: SizedBox(
            height: size,
            width: size,
            child: ClipOval(child: imageWidget),
          ),
        ),
      );
    }

    return DefaultUserImage(height: size, width: size);
  }
}
