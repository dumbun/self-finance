import 'package:material_ui/material_ui.dart';
import 'package:flutter_donation_buttons/donationButtons/buyMeACoffeeButton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/utility/review_helper.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/widgets/drawer_button_widget.dart';
import 'package:self_finance/widgets/user_image_widget.dart';

class DrawerWidget extends ConsumerWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const UserImageWidget(),
                const SizedBox(height: 16),
                DrawerButtonWidget(
                  onTap: () =>
                      Routes.navigateToAccountSettingsView(context: context),
                  text: l10n.account,
                  icon: const Icon(Icons.vpn_key_rounded),
                ),

                DrawerButtonWidget(
                  onTap: () => Utility.sendFeedbackEmail(context),
                  text: l10n.feedback,
                  icon: const Icon(Icons.feedback),
                ),

                DrawerButtonWidget(
                  onTap: () async => await Utility.logout(context, ref),
                  text: l10n.logout,
                  icon: const Icon(
                    Icons.login_rounded,
                    color: AppColors.getErrorColor,
                  ),
                ),

                DrawerButtonWidget(
                  text: l10n.rateUs,
                  icon: const Icon(
                    Icons.star_rounded,
                    color: AppColors.contentColorYellow,
                  ),
                  onTap: () async => await ReviewHelper.openStore(),
                ),

                const BuyMeACoffeeButton(
                  buyMeACoffeeName: Constant.byeMeACoffee,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
