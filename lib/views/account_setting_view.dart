import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/utility/util.dart';
import 'package:self_finance/views/pin_auth_view.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/user_image_update_widget.dart';
import 'package:self_finance/widgets/user_name_update_widget.dart';
import 'package:self_finance/widgets/user_pin_update_widget.dart';

class AccountSettingsView extends StatelessWidget {
  const AccountSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    void navigateToPinAuthView(User user) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) {
            return const PinAuthView();
          },
        ),
        (route) => false,
      );
    }

    void logout(User user) async {
      int response = await AlertDilogs.alertDialogWithTwoAction(
        context,
        Constant.exit,
        Constant.signOutMessage,
      );
      if (response == 1) {
        navigateToPinAuthView(user);
      }
    }

    final Uri toLaunch = Uri.parse(Constant.tAndcUrl);
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const BodyOneDefaultText(
          text: Constant.accountSettings,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(12.sp),
              child: Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.sp),
                      const Hero(
                        tag: Constant.userProfileTag,
                        child: UserImageUpdateWidget(),
                      ),
                      SizedBox(height: 20.sp),
                      const UserNameUpdateWidget(),
                      SizedBox(height: 12.sp),
                      const UserPinUpdateWidget(),
                      SizedBox(height: 12.sp),
                      _buidCard(
                        color: AppColors.getPrimaryColor,
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                        ),
                        onPressed: () {
                          Utility.launchInBrowserView(toLaunch);
                        },
                        title: Constant.tAndcString,
                      ),
                      SizedBox(height: 12.sp),
                      Consumer(
                        builder: (context, ref, child) => ref.watch(asyncUserProvider).when(
                              data: (List<User> data) {
                                return _buidCard(
                                  color: AppColors.getErrorColor,
                                  icon: const Icon(
                                    Icons.logout,
                                  ),
                                  onPressed: () async {
                                    logout(data.first);
                                  },
                                  title: Constant.logout,
                                );
                              },
                              error: (error, stackTrace) => const Center(
                                child: BodyOneDefaultText(text: Constant.errorUserFetch),
                              ),
                              loading: () => const Center(
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: BodyTwoDefaultText(
                text: Constant.loveBharath,
                bold: true,
                color: AppColors.getLigthGreyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card _buidCard({
    required String title,
    required void Function()? onPressed,
    required Widget icon,
    required Color? color,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 14.sp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BodyOneDefaultText(
              text: title,
              bold: true,
            ),
            IconButton(
              onPressed: onPressed,
              icon: icon,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
