import 'package:flutter/material.dart';
import 'package:self_finance/widgets/image_widget.dart';

class AppIcon extends ImageWidget {
  const AppIcon({
    super.key,
    required super.height,
    required super.width,
    required super.child,
    required super.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset("assets/icon/icon_only.png");
  }
}
