import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
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
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        ref
                            .read(userProvider.notifier)
                            .updateProfilePicture(
                              camera: true,
                              id: 1,
                              photoPath: userImageString,
                            );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 60),
                          BodyOneDefaultText(text: "Camera"),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        ref
                            .read(userProvider.notifier)
                            .updateProfilePicture(
                              camera: false,
                              id: 1,
                              photoPath: userImageString,
                            );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.photo, size: 60),
                          BodyOneDefaultText(text: "Gallery"),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        ref
                            .read(userProvider.notifier)
                            .removeProfilePic(userId: 1);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.delete, size: 60),
                          BodyOneDefaultText(text: "Remove"),
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
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: userImageString.isEmpty
                    ? const DefaultUserImage(width: 120, height: 120)
                    : CircularImageWidget(
                        imageData: userImageString,
                        titile: "user",
                      ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.getPrimaryColor,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Icon(
                    size: 24,
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
