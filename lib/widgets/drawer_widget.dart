import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/views/pin_auth_view.dart';
import 'package:self_finance/widgets/ads_banner_widget.dart';
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
        margin: EdgeInsets.symmetric(vertical: 12.sp),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: ref.watch(asyncUserProvider).when(
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
                        : DefaultUserImage(
                            height: 45.sp,
                            width: 45.sp,
                          ),
                    SizedBox(height: 16.sp),
                    _buildDrawerButtons(
                      text: Constant.account,
                      icon: Icons.vpn_key_rounded,
                      onTap: () => Routes.navigateToAccountSettingsView(context: context),
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
                    SizedBox(
                      height: 12.sp,
                    ),
                    const AdsBannerWidget(),
                    SizedBox(
                      height: 20.sp,
                    ),
                    const BodyTwoDefaultText(
                      text: Constant.appVersion,
                      color: AppColors.getLigthGreyColor,
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
            ),
      ),
    );
  }
}
