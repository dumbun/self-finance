import 'package:currency_picker/currency_picker.dart';
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
import 'package:self_finance/widgets/title_widget.dart';
import 'package:self_finance/widgets/user_image_update_widget.dart';
import 'package:self_finance/widgets/user_name_update_buttom_sheet_widget.dart';
import 'package:self_finance/widgets/pin_update_buttom_sheet_widget.dart';

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
                                  // user profile pic
                                  SizedBox(height: 20.sp),
                                  Hero(
                                    tag: Constant.userProfileTag,
                                    child: UserImageUpdateWidget(
                                      userImageString: user.profilePicture,
                                    ),
                                  ),

                                  // user name
                                  SizedBox(height: 20.sp),
                                  _buildNameUpdateButton(
                                    context: context,
                                    userId: user.id!,
                                    userName: user.userName,
                                  ),

                                  // user pin update button
                                  SizedBox(height: 12.sp),
                                  _buildPinUpdateButton(
                                    context: context,
                                    id: user.id!,
                                    userPin: user.userPin,
                                  ),

                                  // user Currency update button
                                  SizedBox(height: 12.sp),
                                  _buildCurrencyUpdateButton(
                                    context: context,
                                    id: user.id!,
                                    currency: user.userCurrency,
                                    ref: ref,
                                  ),

                                  // user terms and condition button
                                  SizedBox(height: 12.sp),
                                  _buildTermsAndConditionButton(),

                                  // user privacy Policy button
                                  SizedBox(height: 12.sp),
                                  _buildPrivacyPolicyButton(),

                                  // logout button
                                  SizedBox(height: 12.sp),
                                  _buildLogoutButton(context: context),
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

  Card _buildNameUpdateButton({
    required BuildContext context,
    required String userName,
    required int userId,
  }) {
    return _buildListTile(
      title: userName,
      onPressed: () => showBottomSheet(
          enableDrag: true,
          context: context,
          builder: (context) {
            return UserNameUpdateButtomSheetWidget(userId: userId, userName: userName);
          }),
      icon: const Icon(
        Icons.edit,
        color: AppColors.getPrimaryColor,
      ),
    );
  }

  Card _buildPinUpdateButton({
    required BuildContext context,
    required int id,
    required String userPin,
  }) {
    return _buildListTile(
      title: 'Change App Pin',
      onPressed: () => showBottomSheet(
        context: context,
        builder: (context) {
          return PinUpdatebuttomSheetWidget(
            id: id,
            userPin: userPin,
          );
        },
      ),
      icon: const Icon(
        Icons.lock,
        color: AppColors.getPrimaryColor,
      ),
    );
  }

  Card _buildCurrencyUpdateButton({
    required BuildContext context,
    required int id,
    required String currency,
    required WidgetRef ref,
  }) {
    return _buildListTile(
      title: 'Change App Currency',
      onPressed: () async {
        if (await AlertDilogs.alertDialogWithTwoAction(context, Constant.alert, Constant.currencyChangeAlert) == 1) {
          showCurrencyPicker(
            theme: CurrencyPickerThemeData(bottomSheetHeight: 90.sp),
            useRootNavigator: true,
            context: context,
            showFlag: true,
            showSearchField: true,
            showCurrencyName: true,
            showCurrencyCode: true,
            onSelect: (Currency selectedCurrency) {
              ref.read(asyncUserProvider.notifier).updateUserCurrency(
                    userId: id,
                    updateUserPin: selectedCurrency.symbol,
                  );
            },
          );
        }
      },
      icon: TitleWidget(
        bold: true,
        color: AppColors.getPrimaryColor,
        text: currency,
      ),
    );
  }

  Card _buildPrivacyPolicyButton() {
    return _buildListTile(
      icon: const Icon(
        Icons.privacy_tip_rounded,
        color: AppColors.getPrimaryColor,
      ),
      onPressed: () => Utility.launchInBrowserView(Constant.pAndPUrl),
      title: Constant.pandp,
    );
  }

  Card _buildTermsAndConditionButton() {
    return _buildListTile(
      icon: const Icon(
        Icons.work_rounded,
        color: AppColors.getPrimaryColor,
      ),
      onPressed: () {
        Utility.launchInBrowserView(Constant.tAndcUrl);
      },
      title: Constant.tAndcString,
    );
  }

  void _logout(int response, BuildContext context) {
    if (response == 1) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) {
            return const PinAuthView();
          },
        ),
        (route) => false,
      );
    }
  }

  Card _buildLogoutButton({required BuildContext context}) {
    return _buildListTile(
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
          (int value) => _logout(value, context),
        );
      },
      title: Constant.logout,
    );
  }

  Card _buildListTile({
    required String title,
    required void Function()? onPressed,
    required Widget icon,
  }) {
    return Card(
      child: ListTile(
        onTap: onPressed,
        trailing: icon,
        title: BodyOneDefaultText(
          text: title,
          bold: true,
        ),
      ),
    );
  }
}
