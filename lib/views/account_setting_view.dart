import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/views/pin_auth_view.dart';
import 'package:self_finance/widgets/backup_with_progress_widget.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/refresh_widget.dart';
import 'package:self_finance/core/fonts/title_widget.dart';
import 'package:self_finance/widgets/user_image_update_widget.dart';
import 'package:self_finance/widgets/user_name_update_buttom_sheet_widget.dart';
import 'package:self_finance/widgets/pin_update_buttom_sheet_widget.dart';

class AccountSettingsView extends StatelessWidget {
  const AccountSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> doBackUp() async {
      return await showAdaptiveDialog(
        useSafeArea: true,
        barrierDismissible: false,
        useRootNavigator: true,
        context: context,
        builder: (BuildContext context) {
          return const Center(child: Card(child: BackupWithProgressWidget()));
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const BodyTwoDefaultText(
          bold: true,
          text: Constant.accountSettings,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(12.sp),
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              return ref
                  .watch(userProvider)
                  .when(
                    data: (User? data) {
                      if (data != null) {
                        return RefreshWidget(
                          onRefresh: () async =>
                              await ref.refresh(userProvider),
                          child: ListView(
                            children: [
                              // user profile pic
                              SizedBox(height: 20.sp),
                              Hero(
                                tag: Constant.userProfileTag,
                                child: UserImageUpdateWidget(
                                  userImageString: data.profilePicture,
                                ),
                              ),

                              // user name
                              SizedBox(height: 20.sp),
                              _buildNameUpdateButton(
                                context: context,
                                userId: data.id!,
                                userName: data.userName,
                              ),

                              // user pin update button
                              SizedBox(height: 12.sp),
                              _buildPinUpdateButton(
                                context: context,
                                id: data.id!,
                                userPin: data.userPin,
                              ),

                              // user Currency update button
                              SizedBox(height: 12.sp),
                              _buildCurrencyUpdateButton(
                                context: context,
                                id: data.id!,
                                currency: data.userCurrency,
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
                              _buildListTile(
                                title: "Backup",
                                onPressed: doBackUp,
                                icon: const Icon(
                                  Icons.backup_rounded,
                                  color: AppColors.contentColorBlue,
                                ),
                              ),

                              SizedBox(height: 12.sp),
                              _buildLogoutButton(
                                context: context,
                                userData: data,
                              ),
                              SizedBox(height: 32.sp),
                            ],
                          ),
                        );
                      } else {
                        return const BodyTwoDefaultText(
                          text: Constant.errorUserFetch,
                        );
                      }
                    },
                    error: (Object error, StackTrace stackTrace) =>
                        const Center(
                          child: BodyOneDefaultText(
                            text: Constant.errorUserFetch,
                          ),
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
        builder: (BuildContext context) {
          return UserNameUpdateButtomSheetWidget(
            userId: userId,
            userName: userName,
          );
        },
      ),
      icon: const Icon(Icons.edit, color: AppColors.getPrimaryColor),
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
        builder: (BuildContext context) {
          return PinUpdatebuttomSheetWidget(id: id, userPin: userPin);
        },
      ),
      icon: const Icon(Icons.lock, color: AppColors.getPrimaryColor),
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
      onPressed: () {
        AlertDilogs.alertDialogWithTwoAction(
          context,
          Constant.alert,
          Constant.currencyChangeAlert,
        ).then((int value) {
          if (value == 1 && context.mounted) {
            showCurrencyPicker(
              theme: CurrencyPickerThemeData(bottomSheetHeight: 90.sp),
              useRootNavigator: true,
              context: context,
              showFlag: true,
              showSearchField: true,
              showCurrencyName: true,
              showCurrencyCode: true,
              onSelect: (Currency selectedCurrency) {
                ref
                    .read(userProvider.notifier)
                    .changeCurrency(
                      id: id,
                      newCurrency: selectedCurrency.symbol,
                    );
              },
            );
          }
        });
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
      icon: const Icon(Icons.work_rounded, color: AppColors.getPrimaryColor),
      onPressed: () {
        Utility.launchInBrowserView(Constant.tAndcUrl);
      },
      title: Constant.tAndcString,
    );
  }

  void _logout(BuildContext context, User userData) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return PinAuthView(userDate: userData);
        },
      ),
      (Route<dynamic> route) => false,
    );
  }

  Card _buildLogoutButton({
    required BuildContext context,
    required User userData,
  }) {
    return _buildListTile(
      icon: const Icon(Icons.logout, color: AppColors.getErrorColor),
      onPressed: () {
        AlertDilogs.alertDialogWithTwoAction(
          context,
          Constant.exit,
          Constant.signOutMessage,
        ).then((int value) {
          BackEnd.close().then((d) {
            if (context.mounted && value == 1) {
              _logout(context, userData);
            }
          });
        });
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
        title: BodyOneDefaultText(text: title, bold: true),
      ),
    );
  }
}
