import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/title_widget.dart';

class CenterTitleTextWidget extends ConsumerWidget {
  const CenterTitleTextWidget({super.key, required this.showUserProfile, required this.user});
  final bool showUserProfile;
  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: TitleWidget(text: user.userName.toLowerCase()),
        ),
        showUserProfile
            ? Align(
                alignment: Alignment.centerRight,
                child: user.profilePicture != ""
                    ? Utility.imageFromBase64String(user.profilePicture)
                    : DefaultUserImage(
                        height: 26.sp,
                      ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
