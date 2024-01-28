import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/widgets/user_image_update_widget.dart';
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
                SizedBox(height: 20.sp),
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
