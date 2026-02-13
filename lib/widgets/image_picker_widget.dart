import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/utility/image_saving_utility.dart';

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
              height: 60.sp,
              padding: EdgeInsets.all(20.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildCard(context, "Camera", Icons.camera_alt),
                  _buildCard(context, "Gallary", Icons.photo_library_sharp),
                  _buildCard(context, "Remove", Icons.delete),
                ],
              ),
            );
          },
        );
      },
      child: Card(
        elevation: 0.sp,
        child: Padding(
          padding: EdgeInsets.all(18.sp),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.sp),
                child: _buildImageDisplay(ref),
              ),
              SizedBox(height: 10.sp),
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
      return SvgPicture.asset(defaultImage, height: 28.sp, width: 28.sp);
    }

    return Image.file(
      File(image.path),
      height: 42.sp,
      width: 42.sp,
      fit: BoxFit.cover,
      cacheWidth: 500,
      cacheHeight: 500,
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon) {
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
          Icon(icon, size: 30.sp),
          BodyOneDefaultText(text: title),
        ],
      ),
    );
  }
}
