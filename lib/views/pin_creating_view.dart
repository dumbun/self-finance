import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/user_db.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/fonts/strong_heading_one_text.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/views/test_db.dart';
import 'package:self_finance/widgets/app_icon.dart';
import 'package:self_finance/widgets/pin_input_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';

class PinCreatingView extends StatefulWidget {
  const PinCreatingView({super.key});

  @override
  State<PinCreatingView> createState() => _PinCreatingViewState();
}

class _PinCreatingViewState extends State<PinCreatingView> {
  final pinController1 = TextEditingController();
  final pinController2 = TextEditingController();
  bool errorVisibility = false;

  @override
  void initState() {
    errorVisibility = false;
    super.initState();
  }

  @override
  void dispose() {
    pinController1.dispose();
    pinController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackgroundColor,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0.sp, vertical: 20.sp),
          width: double.infinity,
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _getAppIcon(),
                SizedBox(height: 20.sp),
                const StrongHeadingOne(
                  color: getPrimaryTextColor,
                  text: "Set Login PIN",
                  bold: true,
                ),
                SizedBox(height: 20.sp),
                const BodyTwoDefaultText(
                  text: securePinMassage,
                  textAlign: TextAlign.center,
                  color: getPrimaryTextColor,
                ),
                SizedBox(height: 20.sp),
                const BodyTwoDefaultText(
                  color: getPrimaryTextColor,
                  text: "Enter your Login Pin",
                  bold: true,
                ),
                SizedBox(height: 12.sp),
                PinInputWidget(
                  pinController: pinController1,
                  obscureText: false,
                ),
                SizedBox(height: 20.sp),
                const BodyTwoDefaultText(
                  text: "Confirm your Login Pin",
                  bold: true,
                  color: getPrimaryTextColor,
                ),
                SizedBox(height: 12.sp),
                PinInputWidget(
                  pinController: pinController2,
                  obscureText: false,
                ),
                SizedBox(height: 20.sp),
                Visibility(
                  visible: errorVisibility,
                  child: const BodyTwoDefaultText(
                    text: "Please enter same pin",
                    color: getErrorColor,
                    bold: true,
                  ),
                ),
                SizedBox(height: 20.sp),
                _buildSetLoginPinButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SizedBox _buildSetLoginPinButton() {
    return SizedBox(
      width: double.infinity,
      child: RoundedCornerButton(
        text: "Set Login Pin",
        onPressed: () {
          if (pinController2.value.text != pinController1.value.text) {
            setState(() {
              errorVisibility = true;
            });
          }
          if (pinController2.value.text == pinController1.value.text) {
            setState(() {
              errorVisibility = false;
            });
            _dbProcess(pinController1);
            // used pushAndRemove method to not allowing the user to go back after creating the pin so that
            // we can make the only one pin
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) => const TestDb()),
              (route) => false,
            );
          }
        },
      ),
    );
  }

  Container _getAppIcon() {
    return Container(
      margin: EdgeInsets.only(bottom: 28.sp),
      child: const AppIcon(),
    );
  }

  void _dbProcess(pinController1) async {
    User newUser = User(
      id: 1,
      userName: "USER",
      userPin: pinController1.text.toString(),
      profilePicture: Uint8List.fromList([0, 0]),
    );
    final bool a = await UserBackEnd.createNewUser(newUser);
    //todo need to show when password is saved

    if (a) debugPrint("user db created");
    if (!a) debugPrint("user db not created");
  }
}
