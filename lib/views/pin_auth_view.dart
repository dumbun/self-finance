import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/strong_heading_one_text.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/widgets/app_icon.dart';
import 'package:self_finance/widgets/pin_input_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';

class PinAuthView extends StatelessWidget {
  const PinAuthView({super.key, required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    final TextEditingController pinController = TextEditingController();
    void getLogin(User user) {
      if (user.userPin == pinController.text) {
        Routes.navigateToDashboard(context: context);
      } else {
        pinController.clear();
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(20.sp),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                user.profilePicture != ""
                    ? Hero(tag: "User-image", child: Utility.imageFromBase64String(user.profilePicture))
                    : const AppIcon(),
                SizedBox(height: 20.sp),
                const StrongHeadingOne(
                  bold: true,
                  text: "Enter your app PIN",
                ),
                SizedBox(height: 20.sp),
                PinInputWidget(
                  pinController: pinController,
                  obscureText: true,
                  validator: (String? p0) {
                    if (p0 != user.userPin) {
                      pinController.clear();
                      return "Please enter the correct pin";
                    } else {
                      Routes.navigateToDashboard(context: context);
                      return null;
                    }
                  },
                ),
                SizedBox(height: 20.sp),
                RoundedCornerButton(text: "Login", onPressed: () => getLogin(user)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
