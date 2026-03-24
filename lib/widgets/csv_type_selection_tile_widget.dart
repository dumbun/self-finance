import 'package:flutter/material.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';

class CsvTypeSelectionTileWidget extends StatelessWidget {
  const CsvTypeSelectionTileWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.getPrimaryColor.withAlpha(15)
              : AppColors.getLigthGreyColor.withAlpha(12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.getPrimaryColor
                : AppColors.getLigthGreyColor.withAlpha(50),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? AppColors.getPrimaryColor
                  : AppColors.getLigthGreyColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodySmallText(
                    text: label,
                    bold: true,
                    color: selected ? AppColors.getPrimaryColor : null,
                  ),
                  BodySmallText(
                    text: description,
                    color: AppColors.getLigthGreyColor,
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: selected
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.getPrimaryColor,
                      size: 20,
                      key: ValueKey('checked'),
                    )
                  : Icon(
                      Icons.circle_outlined,
                      color: AppColors.getLigthGreyColor.withAlpha(120),
                      size: 20,
                      key: const ValueKey('unchecked'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
