import 'package:flutter/widgets.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/image_widget.dart';

class CircularImageWidget extends StatelessWidget {
  const CircularImageWidget({
    super.key,
    required this.imageData,
    required this.titile,
    this.heroTag,
    this.customeSize = 120,
    this.errorBuilder,
  });

  final String imageData;
  final String titile;
  final String? heroTag;
  final double customeSize;
  final Widget? errorBuilder;

  @override
  Widget build(BuildContext context) {
    final Widget fallback =
        errorBuilder ??
        DefaultUserImage(
          userName: titile,
          height: customeSize,
          width: customeSize,
        );

    if (imageData.isNotEmpty) {
      return ClipOval(
        child: ImageWidget(
          errorBuilder: fallback,
          title: titile,
          imagePath: imageData,
          height: customeSize,
          width: customeSize,
        ),
      );
    }
    return fallback;
  }
}
