import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/views/pin_auth_view.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/refresh_widget.dart';
import 'package:self_finance/widgets/user_image_update_widget.dart';
import 'package:self_finance/widgets/user_name_update_widget.dart';
import 'package:self_finance/widgets/user_pin_update_widget.dart';

class AccountSettingsView extends StatelessWidget {
  const AccountSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const BodyTwoDefaultText(
          bold: true,
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
                child: Consumer(
                  builder: (context, ref, child) {
                    return ref.watch(asyncUserProvider).when(
                          data: (List<User> data) {
                            final User user = data.first;
                            return RefreshWidget(
                              onRefresh: () => ref.refresh(asyncUserProvider.future),
                              child: ListView(
                                children: [
                                  SizedBox(height: 20.sp),
                                  Hero(
                                    tag: Constant.userProfileTag,
                                    child: UserImageUpdateWidget(
                                      userImageString: user.profilePicture,
                                    ),
                                  ),
                                  SizedBox(height: 20.sp),
                                  UserNameUpdateWidget(
                                    userId: user.id!,
                                    userName: user.userName,
                                  ),
                                  SizedBox(height: 12.sp),
                                  UserPinUpdateWidget(
                                    id: user.id!,
                                  ),
                                  SizedBox(height: 12.sp),
                                  _buildTermsAndConditionButton(),
                                  SizedBox(height: 12.sp),
                                  _buildPrivacyPolicyButton(),
                                  SizedBox(height: 12.sp),
                                  _buildLogoutButton(),
                                ],
                              ),
                            );
                          },
                          error: (error, stackTrace) => const Center(
                            child: BodyOneDefaultText(text: Constant.errorUserFetch),
                          ),
                          loading: () => const Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        );
                  },
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

  GestureDetector _buildPrivacyPolicyButton() {
    return _buildCard(
      icon: const Icon(
        Icons.key,
        color: AppColors.getPrimaryColor,
      ),
      onPressed: () => Utility.launchInBrowserView(Constant.pAndPUrl),
      title: Constant.pandp,
    );
  }

  GestureDetector _buildTermsAndConditionButton() {
    return _buildCard(
      icon: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: AppColors.getPrimaryColor,
      ),
      onPressed: () {
        Utility.launchInBrowserView(Constant.tAndcUrl);
      },
      title: Constant.tAndcString,
    );
  }

  void navigateToPinAuthView(User user, BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) {
          return const PinAuthView();
        },
      ),
      (route) => false,
    );
  }

  void _logout(User user, int response, BuildContext context) {
    if (response == 1) {
      navigateToPinAuthView(user, context);
    }
  }

  Consumer _buildLogoutButton() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) => ref.watch(asyncUserProvider).when(
            data: (List<User> data) {
              return _buildCard(
                icon: const Icon(
                  Icons.logout,
                  color: AppColors.getErrorColor,
                ),
                onPressed: () {
                  AlertDilogs.alertDialogWithTwoAction(
                    context,
                    Constant.exit,
                    Constant.signOutMessage,
                  ).then(
                    (int value) => _logout(data.first, value, context),
                  );
                },
                title: Constant.logout,
              );
            },
            error: (Object error, StackTrace stackTrace) => const Center(
              child: BodyOneDefaultText(text: Constant.errorUserFetch),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
    );
  }

  GestureDetector _buildCard({
    required String title,
    required void Function()? onPressed,
    required Widget icon,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BodyOneDefaultText(
                text: title,
                bold: true,
              ),
              icon,
            ],
          ),
        ),
      ),
    );
  }
}
