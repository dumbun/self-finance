import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/fonts/strong_heading_one_text.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/widgets/app_icon.dart';
import 'package:self_finance/widgets/pin_input_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';

class PinAuthView extends StatefulWidget {
  const PinAuthView({super.key, required this.user});
  final User user;

  @override
  State<PinAuthView> createState() => _PinAuthViewState();
}

class _PinAuthViewState extends State<PinAuthView> {
  bool _error = false;
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _getLogin(User user) {
    if (user.userPin == _pinController.text) {
      Routes.navigateToDashboard(context: context);
    } else {
      _pinController.clear();
      setState(() {
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.getBackgroundColor,
      body: Container(
        padding: EdgeInsets.all(20.sp),
        alignment: Alignment.center,
        width: double.infinity,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.user.profilePicture != ""
                    ? Utility.imageFromBase64String(widget.user.profilePicture)
                    : const AppIcon(),
                SizedBox(height: 20.sp),
                const StrongHeadingOne(
                  bold: true,
                  text: "Enter your app PIN",
                ),
                SizedBox(height: 20.sp),
                PinInputWidget(
                  pinController: _pinController,
                  obscureText: true,
                ),
                Visibility(
                  visible: _error,
                  child: Container(
                    margin: EdgeInsets.only(top: 20.sp),
                    child: const BodyTwoDefaultText(
                      text: "Enter correct PIN",
                      bold: true,
                      error: true,
                    ),
                  ),
                ),
                SizedBox(height: 20.sp),
                RoundedCornerButton(text: "Login", onPressed: () => _getLogin(widget.user)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
