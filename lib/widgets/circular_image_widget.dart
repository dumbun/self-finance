import 'dart:io';

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/routes.dart';
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
    if (imageData.isNotEmpty) {
      final Image imageWidget = Image.file(File(imageData), fit: BoxFit.fill);
      return GestureDetector(
        onTap: () {
          Routes.navigateToImageView(
            context: context,
            titile: titile,
            imageWidget: imageWidget,
          );
        },
        child: Hero(
          tag: titile,
          child: SizedBox(
            height: 44.sp,
            width: 44.sp,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.sp),
              child: imageWidget,
            ),
          ),
        ),
      );
    } else {
      return DefaultUserImage(height: 44.sp, width: 44.sp);
    }
  }
}
