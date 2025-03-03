import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/utility/user_utility.dart';

class ImagePickerWidget extends ConsumerWidget {
  const ImagePickerWidget({
    super.key,
    required this.text,
    required this.defaultImage,
    required this.imageProvider,
  });

  final String text;
  final String defaultImage;
  final AutoDisposeStateProvider<String> imageProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void doWork() {
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
              children: [
                _buildCard(
                  () {
                    Utility.pickImageFromCamera().then((String value) {
                      if (value != "" && value.isNotEmpty) {
                        ref.read(imageProvider.notifier).update(
                              (String state) => value,
                            );
                      }
                    });
                    Navigator.of(context).pop();
                  },
                  "camera",
                  Icons.camera_alt,
                ),
                _buildCard(
                  () {
                    Utility.pickImageFromGallery().then(
                      (String value) {
                        if (value != "" && value.isNotEmpty) {
                          ref.read(imageProvider.notifier).update(
                                (String state) => value,
                              );
                        }
                      },
                    );
                    Navigator.of(context).pop();
                  },
                  "Gallary",
                  Icons.photo_library_sharp,
                ),
                _buildCard(
                  () {
                    ref.read(imageProvider.notifier).update(
                          (String state) => "",
                        );
                    Navigator.of(context).pop();
                  },
                  "Remove",
                  Icons.delete,
                )
              ],
            ),
          );
        },
      );
    }

    String imageData = ref.watch(imageProvider);
    return GestureDetector(
      onTap: doWork,
      child: Card(
        elevation: 0.sp,
        child: Padding(
          padding: EdgeInsets.all(18.sp),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.sp),
                child: imageData.isEmpty
                    ? SvgPicture.asset(
                        defaultImage,
                        height: 28.sp,
                        width: 28.sp,
                      )
                    : Utility.imageFromBase64String(imageData),
              ),
              SizedBox(height: 10.sp),
              BodyTwoDefaultText(
                text: text,
                bold: true,
              )
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector _buildCard(void Function()? onTap, String title, IconData icon) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 30.sp,
          ),
          BodyOneDefaultText(text: title)
        ],
      ),
    );
  }
}
