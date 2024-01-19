import 'package:flutter/material.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/widgets/default_user_image.dart';

class CircularImageWidget extends StatelessWidget {
  const CircularImageWidget({super.key, required this.imageData, required this.titile});
  final String imageData;
  final String titile;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Routes.navigateToImageView(context: context, imageData: imageData, titile: titile);
      },
      child: imageData.isNotEmpty ? Utility.imageFromBase64String(imageData) : const DefaultUserImage(),
    );
  }
}
