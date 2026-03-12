import 'package:flutter/material.dart';
import 'package:flutter_donation_buttons/donationButtons/buyMeACoffeeButton.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/utility/review_helper.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/widgets/user_Image_widget.dart';

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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const UserImageWIdget(),
                SizedBox(height: 16.sp),
                _buildDrawerButtons(
                  text: Constant.account,
                  icon: Icons.vpn_key_rounded,
                  onTap: () =>
                      Routes.navigateToAccountSettingsView(context: context),
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
                  onTap: () async => await Utility.closeApp(context: context),
                ),
                _buildDrawerButtons(
                  text: "Rate Us",
                  icon: Icons.star_rounded,
                  color: AppColors.contentColorYellow,
                  onTap: () => ReviewHelper.openStore(),
                ),
                const BuyMeACoffeeButton(
                  style: ButtonStyle(
                    maximumSize: WidgetStatePropertyAll(Size.infinite),
                  ),
                  buyMeACoffeeName: "charlierosp",
                ),
                SizedBox(height: 32.sp),
                _getAppVersion(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
