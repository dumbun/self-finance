import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/input_text_field.dart';
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
                Hero(
                  tag: "user-profile-pic",
                  child: _buildImagePicker(),
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

  GestureDetector _buildChangePinButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => Container(
            height: 60.sp,
            //todo add input fields and save button to update the users new pin passcode
            child: InputTextField(),
          ),
        );
      },
      child: const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BodyOneDefaultText(text: "Change Pin"),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.getLigthGreyColor,
              )
            ],
          ),
        ),
      ),
    );
  }

  Consumer _buildImagePicker() {
    return Consumer(
      builder: (context, ref, child) {
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
                          onTap: () {
                            pickImageFromCamera().then((value) {
                              if (value != "" && value.isNotEmpty) {
                                ref
                                    .read(asyncUserProvider.notifier)
                                    .updateUserProfile(userId: 1, updatedImageString: value);
                                // ref.read(userImageProvider.notifier).update((state) => value);
                              }
                            });
                            Navigator.of(context).pop(true);
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
                            Navigator.of(context).pop(true);
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
      },
    );
  }
}

// Consumer(
//                   builder: (context, ref, child) {
//                     return ref.read(asyncUserProvider).when(
//                           data: (data) {
//                             final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//                             final TextEditingController userName = TextEditingController(text: data.first.userName);
//                             final TextEditingController oldPin = TextEditingController(text: data.first.userPin);
//                             final TextEditingController newPin = TextEditingController();
//                             final TextEditingController conformationPin = TextEditingController();

//                             bool validateAndSave() {
//                               final FormState? form = formKey.currentState;
//                               if (form!.validate()) {
//                                 return true;
//                               } else {
//                                 return false;
//                               }
//                             }

//                             return Form(
//                               key: formKey,
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   InputTextField(
//                                     keyboardType: TextInputType.name,
//                                     controller: userName,
//                                     hintText: "User Name",
//                                   ),
//                                   SizedBox(height: 20.sp),
//                                   const BodyOneDefaultText(
//                                     text: "Old pin",
//                                     bold: true,
//                                   ),
//                                   PinInputWidget(readOnly: true, pinController: oldPin, obscureText: false),
//                                   SizedBox(height: 20.sp),
//                                   const BodyOneDefaultText(
//                                     text: "Create new pin",
//                                     bold: true,
//                                   ),
//                                   PinInputWidget(
//                                     pinController: newPin,
//                                     obscureText: false,
//                                   ),
//                                   SizedBox(height: 20.sp),
//                                   const BodyOneDefaultText(
//                                     text: "Conform new pin",
//                                     bold: true,
//                                   ),
//                                   PinInputWidget(
//                                     pinController: conformationPin,
//                                     obscureText: true,
//                                     validator: (value) {
//                                       if (newPin.text == conformationPin.text) {
//                                         if (newPin.text == oldPin.text) {
//                                           return "Try using different pin";
//                                         } else {
//                                           return null;
//                                         }
//                                       } else {
//                                         return "Please enter the same pin";
//                                       }
//                                     },
//                                   ),
//                                   SizedBox(height: 40.sp),
//                                   RoundedCornerButton(
//                                       text: "update",
//                                       onPressed: () {
//                                         if (validateAndSave()) {
//                                           ref.read(asyncUserProvider);
//                                         }
//                                       })
//                                 ],
//                               ),
//                             );
//                           },
//                           error: (error, stackTrace) => const Center(
//                             child: BodyOneDefaultText(text: "Error fetching User Data"),
//                           ),
//                           loading: () => const Center(
//                             child: CircularProgressIndicator.adaptive(),
//                           ),
//                         );
//                   },
//                 ),
