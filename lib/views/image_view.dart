import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:self_finance/fonts/body_text.dart';

class ImageView extends StatelessWidget {
  const ImageView({super.key, required this.imageString, required this.titile});
  final String imageString;
  final String titile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BodyOneDefaultText(
          text: titile,
        ),
      ),
      body: SizedBox(
        child: PhotoView(
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
