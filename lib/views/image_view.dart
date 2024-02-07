import "dart:convert";
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';

class ImageView extends StatelessWidget {
  const ImageView({super.key, required this.imageString, required this.titile});
  final String imageString;
  final String titile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
        forceMaterialTransparency: true,
        title: BodyTwoDefaultText(
          text: titile,
          bold: true,
        ),
      ),
      body: PhotoView(
        heroAttributes: PhotoViewHeroAttributes(tag: titile),
        enablePanAlways: false,
        gaplessPlayback: true,
        tightMode: false,
        wantKeepAlive: true,
        imageProvider: MemoryImage(base64Decode(imageString)),
      ),
    );
  }
}
