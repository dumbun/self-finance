import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/title_widget.dart';

class CenterTitleTextWidget extends StatelessWidget {
  const CenterTitleTextWidget({super.key, required this.showUserProfile, required this.user});
  final bool showUserProfile;
  final User user;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: TitleWidget(text: user.userName.toUpperCase()),
        ),
        showUserProfile
            ? Align(
                alignment: Alignment.centerRight,
                child: user.profilePicture != ""
                    ? GestureDetector(
                        onTap: () {
                          //todo make the screen to show the user detaile and update user details
                        },
                        child: SizedBox(
                          height: 30.sp,
                          width: 30.sp,
                          child: Hero(tag: "User-image", child: Utility.imageFromBase64String(user.profilePicture)),
                        ),
                      )
                    : DefaultUserImage(
                        height: 26.sp,
                      ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
