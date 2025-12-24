import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/auth/auth.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/strong_heading_one_text.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/widgets/app_icon.dart';
import 'package:self_finance/widgets/pin_input_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';

class PinAuthView extends StatefulWidget {
  final List<User> userDate;
  const PinAuthView({super.key, required this.userDate});

  @override
  State<PinAuthView> createState() => _PinAuthViewState();
}

class _PinAuthViewState extends State<PinAuthView> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(12.sp),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      widget.userDate.first.profilePicture != ""
                          ? Hero(
                              tag: Constant.userProfileTag,
                              child: Utility.imageFromBase64String(
                                widget.userDate.first.profilePicture,
                              ),
                            )
                          : const AppIcon(),
                      SizedBox(height: 20.sp),
                      const StrongHeadingOne(
                        bold: true,
                        text: Constant.enterYourAppPin,
                      ),
                      SizedBox(height: 20.sp),
                      PinInputWidget(
                        pinController: _pinController,
                        obscureText: true,
                        validator: (String? p0) {
                          if (p0 == null || p0.isEmpty) {
                            return Constant.enterYourAppPin;
                          } else {
                            if (p0 == widget.userDate.first.userPin) {
                              Routes.navigateToDashboard(context: context);
                              return null;
                            } else {
                              _pinController.clear();
                              return Constant.enterCorrectPin;
                            }
                          }
                        },
                      ),
                      SizedBox(height: 20.sp),
                      RoundedCornerButton(
                        text: Constant.login,
                        onPressed: () => getLogin(widget.userDate.first),
                      ),

                      IconButton(
                        onPressed: () async {
                          await LocalAuthenticator.authenticate().then((
                            bool respond,
                          ) {
                            if (respond && context.mounted) {
                              Routes.navigateToDashboard(context: context);
                            }
                          });
                        },
                        icon: Icon(
                          color: AppColors.getPrimaryColor,
                          size: 32.sp,
                          Icons.fingerprint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getLogin(User user) {
    if (user.userPin == _pinController.text) {
      Routes.navigateToDashboard(context: context);
    } else {
      _pinController.clear();
    }
  }
}
