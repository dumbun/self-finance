import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/theme/app_colors.dart';

class StatusChipWidget extends StatelessWidget {
  const StatusChipWidget({
    super.key,
    required this.status,
    this.smallText = false,
  });

  final bool smallText;
  final String status;

  @override
  Widget build(BuildContext context) {
    final bool isActive = status == Constant.active;
    final l10n = context.l10n;
    final String label = isActive ? l10n.active : l10n.inactive;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.getGreenColor.withAlpha(30)
            : AppColors.getErrorColor.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: smallText
          ? BodySmallText(
              text: label,
              bold: true,
              color: isActive
                  ? AppColors.getGreenColor
                  : AppColors.getErrorColor,
            )
          : BodyTwoDefaultText(
              text: label,
              bold: true,
              color: isActive
                  ? AppColors.getGreenColor
                  : AppColors.getErrorColor,
            ),
    );
  }
}
