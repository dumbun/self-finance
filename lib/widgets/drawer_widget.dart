import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/views/pin_auth_view.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';

class DrawerWidget extends ConsumerWidget {
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

  void _logout(User user, BuildContext context) {
    AlertDilogs.alertDialogWithTwoAction(
      context,
      Constant.exit,
      Constant.signOutMessage,
    ).then((int value) {
      BackEnd.close().then((bool respond) {
        if (value == 1 && context.mounted && respond) {
          _navigateToPinAuthView(user, context);
        }
      });
    });
  }

  void _navigateToPinAuthView(User user, BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const PinAuthView();
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: ref
            .watch(asyncUserProvider)
            .when(
              data: (List<User> data) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    data.first.profilePicture.isNotEmpty
                        ? CircularImageWidget(
                            imageData: data.first.profilePicture,
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
                      onTap: () => _logout(data.first, context),
                    ),
                    SizedBox(height: 12.sp),
                    SizedBox(height: 20.sp),
                    _getAppVersion(),
                  ],
                );
              },
              error: (Object _, StackTrace _) =>
                  const Center(child: Text(Constant.error)),
              loading: () =>
                  const Center(child: CircularProgressIndicator.adaptive()),
            ),
      ),
    );
  }

  FutureBuilder<String> _getAppVersion() {
    return FutureBuilder<String>(
      future: Utility.getAppVersion(), // async work
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
}
