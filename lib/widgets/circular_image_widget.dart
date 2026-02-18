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
    this.customeSize,
    this.cache,
  });

  final String imageData;
  final String titile;
  final double? customeSize;
  final int? cache;

  @override
  Widget build(BuildContext context) {
    final File file = File(imageData);
    final double size = customeSize ?? 44.sp;
    if (cache != null) {
      if (imageData.isNotEmpty && file.existsSync()) {
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
              child: ClipOval(
                child: Image.file(
                  file,
                  height: size,
                  width: size,
                  cacheWidth: cache,
                  cacheHeight: cache,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      }
      return DefaultUserImage(height: size, width: size, cache: cache);
    }

    final int cacheSize = (size * MediaQuery.of(context).devicePixelRatio)
        .round();

    if (imageData.isNotEmpty && file.existsSync()) {
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
            child: ClipOval(
              child: Image.file(
                file,
                height: size,
                width: size,
                cacheWidth: cacheSize,
                cacheHeight: cacheSize,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    }

    return DefaultUserImage(height: size, width: size, cache: cacheSize);
  }
}
