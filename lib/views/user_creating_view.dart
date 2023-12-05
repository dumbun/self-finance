// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/user_db.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

final userImageProvider = StateProvider<String>((ref) {
  return "";
});

final createNewEntryProvider = FutureProvider.autoDispose.family<bool, User>((ref, user) async {
  final bool result = await UserBackEnd.createNewUser(user);
  return result;
});

class UserCreationView extends ConsumerWidget {
  UserCreationView({required this.pin, super.key});
  final String pin;
  final double height = 55.sp;

  final double width = 55.sp;
  final TextEditingController _nameInput = TextEditingController();
  Widget? pickedItemImage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String userProfilePicString = ref.watch(userImageProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          try {
            _createUser(context, pin, _nameInput.text, userProfilePicString);
          } catch (e) {
            snackBarWidget(context: context, message: "$e");
          }
        },
        backgroundColor: getPrimaryColor,
        enableFeedback: true,
        autofocus: true,
        isExtended: true,
        mini: false,
        shape: const CircleBorder(),
        tooltip: "Next",
        splashColor: getPrimaryColor,
        focusElevation: 40.sp,
        child: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: getBackgroundColor,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          padding: EdgeInsets.all(18.sp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildImagePickWidget(ref),
              SizedBox(height: 24.sp),
              InputTextField(
                controller: _nameInput,
                hintText: pleaseEnterTheName,
                keyboardType: TextInputType.name,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createUser(BuildContext context, String pin, String userName, String userPhoto) async {
    try {
      final user = User(userName: userName, userPin: pin, profilePicture: userPhoto, id: 1);
      final result = await UserBackEnd.createNewUser(user);
      if (result) {
        navigateToDashboard(context, user);
      } else {
        AlertDilogs.alertDialogWithOneAction(context, "error", 'Please try after some time 1');
      }
    } catch (e) {
      AlertDilogs.alertDialogWithOneAction(context, "error", 'Please try after some time 2');
    }
  }

  navigateToDashboard(ctx, User user) {
    Routes.navigateToDashboard(context: ctx, user: user);
    snackBarWidget(context: ctx, message: "success : saved successfully ");
  }

  Widget _buildImagePickWidget(WidgetRef ref) {
    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.sp),
              child: pickedItemImage ??
                  DefaultUserImage(
                    height: height,
                    width: width,
                  ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {
                pickImageFromGallery().then(
                  (value) {
                    if (value != "" && value.isNotEmpty) {
                      pickedItemImage = Utility.imageFromBase64String(
                        value,
                        height: height,
                        width: width,
                      );
                    }
                    ref.read(userImageProvider.notifier).state = value;
                  },
                );
              },
              child: SvgPicture.asset(
                "assets/icon/edit_icon.svg",
                height: 30.sp,
                width: 30.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
