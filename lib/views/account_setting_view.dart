import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/widgets/backup_with_progress_widget.dart';
import 'package:self_finance/widgets/biometric_switch_widget.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/core/fonts/title_widget.dart';
import 'package:self_finance/widgets/notification_switch_widget.dart';
import 'package:self_finance/widgets/theme_switch_widget.dart';
import 'package:self_finance/widgets/user_image_update_widget.dart';
import 'package:self_finance/widgets/user_name_update_buttom_sheet_widget.dart';
import 'package:self_finance/widgets/pin_update_buttom_sheet_widget.dart';

class AccountSettingsView extends StatelessWidget {
  const AccountSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> doBackUp() async {
      return await showAdaptiveDialog<void>(
        useSafeArea: true,
        barrierDismissible: false,
        useRootNavigator: true,
        context: context,
        builder: (BuildContext context) {
          return const Center(child: Card(child: BackupWithProgressWidget()));
        },
      );
    }

    final double height = 12.sp;

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
                  .watch<AsyncValue<User?>>(userProvider)
                  .when<Widget>(
                    data: (User? data) {
                      if (data != null) {
                        return RefreshIndicator(
                          onRefresh: () async =>
                              ref.refresh(userProvider.future).ignore(),
                          child: ListView(
                            children: <Widget>[
                              // user profile pic
                              SizedBox(height: height),
                              Hero(
                                tag: Constant.userProfileTag,
                                child: UserImageUpdateWidget(
                                  userImageString: data.profilePicture,
                                ),
                              ),

                              // user name
                              SizedBox(height: height),
                              _buildNameUpdateButton(
                                context: context,
                                userId: data.id!,
                                userName: data.userName,
                              ),

                              // user pin update button
                              SizedBox(height: height),
                              _buildPinUpdateButton(
                                context: context,
                                id: data.id!,
                                userPin: data.userPin,
                              ),

                              // user Currency update button
                              SizedBox(height: height),
                              _buildCurrencyUpdateButton(
                                context: context,
                                id: data.id!,
                                currency: data.userCurrency,
                                ref: ref,
                              ),

                              // user terms and condition button
                              SizedBox(height: height),
                              _buildTermsAndConditionButton(),

                              // user privacy Policy button
                              SizedBox(height: height),
                              _buildPrivacyPolicyButton(),

                              // BackUp button
                              SizedBox(height: height),
                              _buildListTile(
                                title: "Backup",
                                onPressed: doBackUp,
                                icon: const Icon(
                                  Icons.backup_rounded,
                                  color: AppColors.contentColorBlue,
                                ),
                              ),

                              SizedBox(height: height),
                              _buildLogoutButton(
                                context: context,
                                userData: data,
                              ),

                              SizedBox(height: height),
                              const ThemeSwitchWidget(),

                              SizedBox(height: height),
                              const NotificationSwitchWidget(),

                              SizedBox(height: height),
                              const BiometricSwitchWidget(),

                              SizedBox(height: height),
                            ],
                          ),
                        );
                      } else {
                        return const BodyTwoDefaultText(
                          text: Constant.errorUserFetch,
                        );
                      }
                    },
                    error: (_, _) => const Center(
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
        ).then((int value) async {
          if (value == 1 && context.mounted) {
            await Utility.closeApp(context: context, userData: userData);
          }
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
