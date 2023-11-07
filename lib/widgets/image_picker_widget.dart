import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/widgets/image_widget.dart';

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({
    super.key,
    this.onTap,
    required this.defaultImage,
    this.pickedImage,
  });
  final void Function()? onTap;
  final String defaultImage;
  final ClipRRect? pickedImage;
  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.sp),
        child: widget.pickedImage ??
            ImageWidget(
              height: 25.sp,
              width: 25.sp,
              child: Svg(widget.defaultImage, color: getPrimaryColor),
              shape: BoxShape.rectangle,
            ),
      ),
    );
  }
}
