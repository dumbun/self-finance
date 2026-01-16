import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/utility/image_saving_utility.dart';

final AutoDisposeStateProvider<XFile?> imageProvider =
    StateProvider.autoDispose<XFile?>((ref) {
      return null;
    });
final AutoDisposeStateProvider<XFile?> proofProvider =
    StateProvider.autoDispose<XFile?>((ref) {
      return null;
    });
final AutoDisposeStateProvider<XFile?> itemProvider =
    StateProvider.autoDispose<XFile?>((ref) {
      return null;
    });

class ImagePickerWidget extends StatelessWidget {
  const ImagePickerWidget({
    super.key,
    required this.imageProvier,
    required this.title,
    required this.defaultImage,
  });

  final String title;
  final String defaultImage;
  final AutoDisposeStateProvider<XFile?> imageProvier;

  @override
  Widget build(BuildContext context) {
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
                  _buildCard("Camera", Icons.camera_alt),
                  _buildCard("Gallary", Icons.photo_library_sharp),
                  _buildCard("Remove", Icons.delete),
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
              Consumer(
                builder: (context, ref, child) {
                  final XFile? image = ref.watch(imageProvier);
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8.sp),
                    child: image == null
                        ? SvgPicture.asset(
                            defaultImage,
                            height: 28.sp,
                            width: 28.sp,
                          )
                        : Image.file(
                            File(image.path),
                            height: 48.sp,
                            width: 48.sp,
                            fit: BoxFit.fill,
                          ),
                  );
                },
              ),
              SizedBox(height: 10.sp),
              BodyTwoDefaultText(text: title, bold: true),
            ],
          ),
        ),
      ),
    );
  }

  Consumer _buildCard(String title, IconData icon) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return GestureDetector(
          onTap: () async {
            if (title == "Remove") {
              ref.read(imageProvier.notifier).update((XFile? state) => null);
              Navigator.pop(context);
            } else if (title == "Camera") {
              final XFile? image = await ImageSavingUtility.doPickImage(
                camera: true,
              );
              ref.read(imageProvier.notifier).update((XFile? state) => image);
              if (context.mounted) {
                Navigator.pop(context);
              }
            } else {
              final XFile? image = await ImageSavingUtility.doPickImage(
                camera: false,
              );
              ref.read(imageProvier.notifier).update((XFile? state) => image);
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
      },
    );
  }
}
