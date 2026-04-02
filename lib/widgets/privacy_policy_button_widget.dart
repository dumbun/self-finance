import 'package:flutter/material.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';

class PrivacyPolicyButtonWidget extends StatelessWidget {
  const PrivacyPolicyButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => Utility.launchInBrowserView(Constant.pAndPUrl),
        trailing: const Icon(
          Icons.privacy_tip_rounded,
          color: AppColors.getPrimaryColor,
        ),
        title: const BodyOneDefaultText(text: Constant.pandp, bold: true),
      ),
    );
  }
}
