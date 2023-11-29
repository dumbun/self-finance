import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/title_widget.dart';

class CenterTitleTextWidget extends StatelessWidget {
  const CenterTitleTextWidget({super.key, required this.title, required this.showUserProfile});

  final String title;
  final bool showUserProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(),
        Center(child: TitleWidget(text: title)),
        showUserProfile ? DefaultUserImage(height: 20.sp) : const SizedBox()
      ],
    );
  }
}
