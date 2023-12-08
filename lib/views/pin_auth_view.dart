import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/fonts/strong_heading_one_text.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/user_backend_provider.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/widgets/app_icon.dart';
import 'package:self_finance/widgets/pin_input_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';

class PinAuthView extends ConsumerStatefulWidget {
  const PinAuthView({super.key});

  @override
  ConsumerState<PinAuthView> createState() => _PinAuthViewState();
}

class _PinAuthViewState extends ConsumerState<PinAuthView> {
  bool _error = false;
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _getLogin(String userPin) {
    if (userPin == _pinController.text) {
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
      backgroundColor: getBackgroundColor,
      body: ref.watch(userDataProvider).when(
          data: (data) {
            User user = data[0];
            return Container(
              padding: EdgeInsets.all(20.sp),
              alignment: Alignment.center,
              width: double.infinity,
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      user.profilePicture != "" ? Utility.imageFromBase64String(user.profilePicture) : const AppIcon(),
                      SizedBox(height: 20.sp),
                      const StrongHeadingOne(
                        bold: true,
                        text: "Enter your app PIN",
                        color: getPrimaryTextColor,
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
                      RoundedCornerButton(text: "Login", onPressed: () => _getLogin(user.userPin)),
                    ],
                  ),
                ),
              ),
            );
          },
          error: (_, __) => const Center(child: BodyOneDefaultText(text: "Error fetching app data please restart")),
          loading: () => const Center(child: CircularProgressIndicator.adaptive())),
    );
  }
}
