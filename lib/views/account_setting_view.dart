import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/widgets/user_image_update_widget.dart';
import 'package:self_finance/widgets/user_name_update_widget.dart';
import 'package:self_finance/widgets/user_pin_update_widget.dart';

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
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.sp),
                    const Hero(
                      tag: "user-profile-pic",
                      child: UserImageUpdateWidget(),
                    ),
                    SizedBox(height: 20.sp),
                    const UserNameUpdateWidget(),
                    SizedBox(height: 18.sp),
                    const UserPinUpdateWidget(),
                  ],
                ),
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: BodyTwoDefaultText(
                  text: "self-finance ❤️ India",
                  color: AppColors.getLigthGreyColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
