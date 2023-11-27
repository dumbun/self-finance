import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/theme/colors.dart';
import 'dart:convert';

class ImageView extends StatelessWidget {
  const ImageView({super.key, required this.imageString, required this.titile});
  final String imageString;
  final String titile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: getTransparentColor,
        title: BodyOneDefaultText(text: titile),
      ),
      body: SizedBox(
        child: PhotoView(
          heroAttributes: PhotoViewHeroAttributes(tag: titile),
          enablePanAlways: false,
          gaplessPlayback: true,
          tightMode: false,
          wantKeepAlive: true,
          imageProvider: MemoryImage(
            base64Decode(imageString),
          ),
        ),
      ),
    );
  }
}
