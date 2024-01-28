import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/user_name_update_widget.dart';

class AccountSettingsView extends StatelessWidget {
  const AccountSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const BodyOneDefaultText(
          text: "Account Setting",
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Hero(
                  tag: "user-profile-pic",
                  child: UserImageUpdateWidget(),
                ),
                SizedBox(height: 20.sp),
                const UserNameUpdateWidget()
                // _buildChangePinButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserImageUpdateWidget extends ConsumerWidget {
  const UserImageUpdateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
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
                        await pickImageFromCamera().then((value) {
                          if (value != "" && value.isNotEmpty) {
                            ref
                                .read(asyncUserProvider.notifier)
                                .updateUserProfile(userId: 1, updatedImageString: value);
                          }
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 30.sp,
                          ),
                          const BodyOneDefaultText(text: "Camera")
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        pickImageFromGallery().then((value) {
                          if (value != "" && value.isNotEmpty) {
                            ref
                                .read(asyncUserProvider.notifier)
                                .updateUserProfile(userId: 1, updatedImageString: value);
                          }
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo,
                            size: 30.sp,
                          ),
                          const BodyOneDefaultText(text: "Gallery")
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
                child: ref.watch(asyncUserProvider).when(
                      data: (data) {
                        return data.first.profilePicture.isEmpty
                            ? DefaultUserImage(
                                width: 46.sp,
                                height: 46.sp,
                              )
                            : SizedBox(
                                height: 46.sp,
                                width: 46.sp,
                                child: Utility.imageFromBase64String(
                                  data.first.profilePicture,
                                ),
                              );
                      },
                      error: (error, stackTrace) => const Center(
                        child: BodyOneDefaultText(
                          text: "error fetching user data",
                        ),
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.getPrimaryColor),
                  padding: EdgeInsets.all(12.sp),
                  child: Icon(
                    size: 24.sp,
                    Icons.edit_rounded,
                    color: AppColors.getBackgroundColor,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
