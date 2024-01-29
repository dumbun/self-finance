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
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(12.sp),
              child: Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
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
                      SizedBox(height: 12.sp),
                      const UserPinUpdateWidget(),
                      SizedBox(height: 12.sp),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 14.sp),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              BodyOneDefaultText(
                                text: "Terms and Conditions",
                                bold: true,
                              ),
                              IconButton(onPressed: () {}, icon: Icon(Icons.arrow_forward_ios_rounded))
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
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
    );
  }
}
