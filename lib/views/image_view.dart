import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';

class ImageView extends StatelessWidget {
  const ImageView({super.key, required this.titile, required this.imagePath});

  final String titile;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: BodyTwoDefaultText(text: titile),
      ),
      body: Hero(
        tag: titile,
        child: PhotoView(imageProvider: FileImage(File(imagePath))),
      ),
    );
  }
}
