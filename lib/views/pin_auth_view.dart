import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/fonts/strong_heading_one_text.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/theme/colors.dart';
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
  bool error = false;
  TextEditingController pinController = TextEditingController();

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackgroundColor,
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 60.sp),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AppIcon(),
              SizedBox(height: 20.sp),
              const StrongHeadingOne(
                bold: true,
                text: "Enter your app PIN",
                color: getPrimaryTextColor,
              ),
              SizedBox(height: 20.sp),
              PinInputWidget(
                pinController: pinController,
                obscureText: true,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.sp),
                child: Visibility(
                  visible: error,
                  child: const BodyTwoDefaultText(
                    text: "Enter correct PIN",
                    bold: true,
                    error: true,
                  ),
                ),
              ),
              RoundedCornerButton(text: "Login", onPressed: () => _getLogin()),
            ],
          ),
        ),
      ),
    );
  }

  void _getLogin() {
    if (widget.user.userPin == pinController.text) {
      Routes.navigateToDashboard(context: context, user: widget.user);
    } else {
      pinController.clear();
      setState(() {
        error = true;
      });
    }
  }
}
