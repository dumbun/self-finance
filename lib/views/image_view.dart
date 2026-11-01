import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:photo_view/photo_view.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';

class ImageView extends StatelessWidget {
  const ImageView({super.key, required this.titile, required this.imagePath});

  final String titile;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = imagePath.startsWith('http://') ||
        imagePath.startsWith('https://');
    final ImageProvider provider = isNetwork
        ? NetworkImage(imagePath)
        : FileImage(File(imagePath)) as ImageProvider;

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: BodyTwoDefaultText(text: titile),
      ),
      body: PhotoView(
        imageProvider: provider,
        errorBuilder: (_, _, _) =>
            const Center(child: Icon(Icons.broken_image_outlined, size: 48)),
      ),
    );
  }
}
