import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({
    super.key,
    required this.height,
    required this.width,
    required this.child,
    required this.shape,
  });

  final double height;
  final double width;
  final Widget child;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: shape,
      ),
      child: CircleAvatar(child: child),
    );
  }
}
