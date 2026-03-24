import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/utility/image_saving_utility.dart';
import 'package:self_finance/widgets/image_widget.dart';

class ImagePickerWidget extends ConsumerWidget {
  const ImagePickerWidget({
    super.key,
    required this.imageProvider,
    required this.onSetImage,
    required this.onClearImage,
    required this.title,
    required this.defaultImage,
  });

  final String title;
  final String defaultImage;
  final ProviderListenable<XFile?> imageProvider;
  final void Function(XFile?) onSetImage;
  final void Function() onClearImage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          enableDrag: true,
          useSafeArea: true,
          context: context,
          builder: (BuildContext context) {
            return Container(
              alignment: Alignment.center,
              height: 200,
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildCard(
                    context,
                    "Camera",
                    const Icon(Icons.camera_alt, size: 40),
                  ),
                  _buildCard(
                    context,
                    "Gallary",
                    const Icon(Icons.photo_library_sharp, size: 40),
                  ),
                  _buildCard(
                    context,
                    "Remove",
                    const Icon(Icons.delete, size: 40),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImageDisplay(ref),
              ),
              const SizedBox(height: 10),
              BodyTwoDefaultText(text: title, bold: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageDisplay(WidgetRef ref) {
    final XFile? image = ref.watch(imageProvider);

    if (image == null) {
      return Image.asset(defaultImage, height: 62, width: 62);
    }
    return ImageWidget(
      imagePath: image.path,
      height: 62,
      width: 62,
      title: title,
      showImage: false,
    );
  }

  Widget _buildCard(BuildContext context, String title, Icon icon) {
    return GestureDetector(
      onTap: () async {
        if (title == "Remove") {
          onClearImage();
          Navigator.pop(context);
        } else if (title == "Camera") {
          final XFile? image = await ImageSavingUtility.doPickImage(
            camera: true,
          );
          onSetImage(image);
          if (context.mounted) {
            Navigator.pop(context);
          }
        } else {
          final XFile? image = await ImageSavingUtility.doPickImage(
            camera: false,
          );
          onSetImage(image);
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          BodyOneDefaultText(text: title),
        ],
      ),
    );
  }
}
