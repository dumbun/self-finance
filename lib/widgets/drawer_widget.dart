import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/views/pin_auth_view.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              return ref.watch(asyncUserProvider).when(
                    data: (List<User> data) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Hero(
                            tag: Constant.userProfileTag,
                            child: data.first.profilePicture.isNotEmpty
                                ? Utility.imageFromBase64String(
                                    data.first.profilePicture,
                                    height: 45.sp,
                                    width: 45.sp,
                                  )
                                : DefaultUserImage(
                                    height: 45.sp,
                                    width: 45.sp,
                                  ),
                          ),
                          SizedBox(height: 24.sp),
                          _buildDrawerButtons(
                            text: Constant.account,
                            icon: Icons.vpn_key_rounded,
                            onTap: () => Routes.navigateToAccountSettingsView(context: context),
                          ),
                          SizedBox(height: 12.sp),
                          _buildDrawerButtons(
                            text: Constant.logout,
                            icon: Icons.login_rounded,
                            color: AppColors.getErrorColor,
                            onTap: () => _logout(data.first, context),
                          ),
                        ],
                      );
                    },
                    error: (Object _, StackTrace __) => const Center(
                      child: Text(Constant.error),
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerButtons(
      {required String text, required IconData icon, required void Function()? onTap, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BodyOneDefaultText(
                text: text,
                bold: true,
              ),
              Icon(
                icon,
                color: color,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _logout(User user, BuildContext context) {
    AlertDilogs.alertDialogWithTwoAction(
      context,
      Constant.exit,
      Constant.signOutMessage,
    ).then((value) {
      if (value == 1) {
        _navigateToPinAuthView(user, context);
      }
    });
  }

  void _navigateToPinAuthView(User user, BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
      builder: (context) {
        return const PinAuthView();
      },
    ), (route) => false);
  }
}
