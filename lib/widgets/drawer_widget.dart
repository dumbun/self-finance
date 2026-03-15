import 'package:flutter/material.dart';
import 'package:flutter_donation_buttons/donationButtons/buyMeACoffeeButton.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/utility/review_helper.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/widgets/app_version_widget.dart';
import 'package:self_finance/widgets/drawer_button_widget.dart';
import 'package:self_finance/widgets/user_image_widget.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const UserImageWidget(),
                const SizedBox(height: 16),
                DrawerButtonWidget(
                  onTap: () =>
                      Routes.navigateToAccountSettingsView(context: context),
                  text: Constant.account,
                  icon: const Icon(Icons.vpn_key_rounded),
                ),

                DrawerButtonWidget(
                  onTap: () => Utility.sendFeedbackEmail(context),
                  text: "Feedback",
                  icon: const Icon(Icons.feedback),
                ),

                DrawerButtonWidget(
                  onTap: () async => await Utility.closeApp(context: context),
                  text: Constant.logout,
                  icon: const Icon(
                    Icons.login_rounded,
                    color: AppColors.getErrorColor,
                  ),
                ),

                DrawerButtonWidget(
                  text: "Rate Us",
                  icon: const Icon(
                    Icons.star_rounded,
                    color: AppColors.contentColorYellow,
                  ),
                  onTap: () => ReviewHelper.openStore(),
                ),

                const BuyMeACoffeeButton(
                  style: ButtonStyle(
                    maximumSize: WidgetStatePropertyAll(Size.infinite),
                  ),
                  buyMeACoffeeName: "charlierosp",
                ),

                const SizedBox(height: 32),

                const AppVersionWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
