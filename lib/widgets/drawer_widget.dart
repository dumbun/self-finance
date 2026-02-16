import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/views/pin_auth_view.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  Widget _buildDrawerButtons({
    required String text,
    required IconData icon,
    required void Function()? onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 12.sp),
        child: ListTile(
          title: BodyOneDefaultText(text: text, bold: true),
          trailing: Icon(icon, color: color),
        ),
      ),
    );
  }

  void _logout(User userData, BuildContext context) {
    AlertDilogs.alertDialogWithTwoAction(
      context,
      Constant.exit,
      Constant.signOutMessage,
    ).then((int value) {
      BackEnd.close().then((_) {
        if (value == 1 && context.mounted) {
          _navigateToPinAuthView(userData, context);
        }
      });
    });
  }

  void _navigateToPinAuthView(User userData, BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return PinAuthView(userDate: userData);
        },
      ),
      (route) => false,
    );
  }

  FutureBuilder<String> _getAppVersion() {
    return FutureBuilder<String>(
      future: Utility.getAppVersion(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState case ConnectionState.waiting) {
          return const BodyTwoDefaultText(text: 'Loading....');
        } else {
          if (snapshot.hasError) {
            return BodyTwoDefaultText(text: 'Error: ${snapshot.error}');
          } else {
            return BodyTwoDefaultText(text: 'Version: ${snapshot.data}');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            return ref
                .watch(userProvider)
                .when(
                  data: (User? user) {
                    if (user != null) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          user.profilePicture.isNotEmpty
                              ? CircularImageWidget(
                                  imageData: user.profilePicture,
                                  titile: 'Account Profile Image',
                                )
                              : DefaultUserImage(height: 45.sp, width: 45.sp),
                          SizedBox(height: 16.sp),
                          _buildDrawerButtons(
                            text: Constant.account,
                            icon: Icons.vpn_key_rounded,
                            onTap: () => Routes.navigateToAccountSettingsView(
                              context: context,
                            ),
                          ),
                          _buildDrawerButtons(
                            text: "Feedback",
                            icon: Icons.feedback,
                            onTap: () => Utility.sendFeedbackEmail(context),
                          ),
                          _buildDrawerButtons(
                            text: Constant.logout,
                            icon: Icons.login_rounded,
                            color: AppColors.getErrorColor,
                            onTap: () => _logout(user, context),
                          ),
                          SizedBox(height: 12.sp),
                          SizedBox(height: 20.sp),
                          _getAppVersion(),
                        ],
                      );
                    } else {
                      return const BodyTwoDefaultText(
                        text: Constant.errorUserFetch,
                      );
                    }
                  },
                  error: (Object error, StackTrace stackTrace) =>
                      const BodyTwoDefaultText(text: Constant.errorUserFetch),
                  loading: () =>
                      const Center(child: CircularProgressIndicator.adaptive()),
                );
          },
        ),
      ),
    );
  }
}
