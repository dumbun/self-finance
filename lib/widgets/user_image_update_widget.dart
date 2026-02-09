import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/image_saving_utility.dart';
import 'package:self_finance/widgets/default_user_image.dart';

class UserImageUpdateWidget extends ConsumerWidget {
  const UserImageUpdateWidget({super.key, required this.userImageString});

  final String userImageString;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: GestureDetector(
        onTap: () async {
          await showModalBottomSheet(
            showDragHandle: true,
            enableDrag: true,
            useSafeArea: true,
            context: context,
            builder: (BuildContext context) {
              return Container(
                alignment: Alignment.center,
                height: 60.sp,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final String newImagePath =
                            await ImageSavingUtility.saveImage(
                              location: 'user',
                              image: await ImageSavingUtility.doPickImage(
                                camera: true,
                              ),
                            );
                        if (newImagePath.isNotEmpty) {
                          ref
                              .read(asyncUserProvider.notifier)
                              .updateUserProfile(
                                userId: 1,
                                updatedImageString: newImagePath,
                              );
                        }
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 30.sp),
                          const BodyOneDefaultText(text: "Camera"),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final String newImagePath =
                            await ImageSavingUtility.saveImage(
                              location: 'user',
                              image: await ImageSavingUtility.doPickImage(
                                camera: false,
                              ),
                            );
                        if (newImagePath.isNotEmpty) {
                          ref
                              .read(asyncUserProvider.notifier)
                              .updateUserProfile(
                                userId: 1,
                                updatedImageString: newImagePath,
                              );
                        }

                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.photo, size: 30.sp),
                          const BodyOneDefaultText(text: "Gallery"),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: SizedBox(
          width: 48.sp,
          height: 48.sp,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: userImageString.isEmpty
                    ? DefaultUserImage(width: 46.sp, height: 46.sp)
                    : ClipRRect(
                        borderRadius: BorderRadiusGeometry.all(
                          Radius.circular(100.sp),
                        ),
                        child: SizedBox(
                          height: 46.sp,
                          width: 46.sp,
                          child: Image.file(
                            File(userImageString),
                            height: 500,
                            width: 500,
                            fit: BoxFit.cover,
                            cacheWidth: 500,
                            cacheHeight: 500,
                          ),
                        ),
                      ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.getPrimaryColor,
                  ),
                  padding: EdgeInsets.all(12.sp),
                  child: Icon(
                    size: 24.sp,
                    Icons.edit_rounded,
                    color: AppColors.getBackgroundColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
