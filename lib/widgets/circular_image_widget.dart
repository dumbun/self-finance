import 'package:flutter/widgets.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/image_widget.dart';

class CircularImageWidget extends StatelessWidget {
  const CircularImageWidget({
    super.key,
    required this.imageData,
    required this.titile,
    this.customeSize = 120,
    this.errorBuilder = const SizedBox.shrink(),
  });

  final String imageData;
  final String titile;
  final double customeSize;
  final Widget errorBuilder;

  @override
  Widget build(BuildContext context) {
    if (imageData.isNotEmpty) {
      return Hero(
        tag: titile,
        child: ClipOval(
          child: ImageWidget(
            errorBuilder: errorBuilder,
            title: titile,
            imagePath: imageData,
            height: customeSize,
            width: customeSize,
          ),
        ),
      );
    }
    return DefaultUserImage(height: customeSize, width: customeSize);
  }
}
