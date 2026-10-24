import 'package:material_ui/material_ui.dart';
import 'package:flutter/widget_previews.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/previews/preview_annotations.dart';
import 'package:self_finance/widgets/app_icon_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:self_finance/widgets/section_header_widget.dart';
import 'package:self_finance/widgets/status_chip_widget.dart';

// ── Buttons Previews ─────────────────────────────────────────────────────────

@MultiBrightnessPreview(name: 'Primary Button', previewGroup: 'Buttons')
Widget previewPrimaryButton() {
  return Material(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: RoundedCornerButton(
        text: 'Continue',
        onPressed: () {},
      ),
    ),
  );
}

@MultiBrightnessPreview(name: 'Button with Icon', previewGroup: 'Buttons')
Widget previewIconButton() {
  return Material(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: RoundedCornerButton(
        text: 'Add Customer',
        icon: Icons.person_add_rounded,
        onPressed: () {},
      ),
    ),
  );
}

// ── Status Chips Previews ───────────────────────────────────────────────────

@MultiBrightnessPreview(name: 'Active Chip', previewGroup: 'Chips')
Widget previewActiveChip() {
  return const Material(
    child: Center(
      child: StatusChipWidget(status: Constant.active),
    ),
  );
}

@MultiBrightnessPreview(name: 'Inactive Chip', previewGroup: 'Chips')
Widget previewInactiveChip() {
  return const Material(
    child: Center(
      child: StatusChipWidget(status: 'Inactive'),
    ),
  );
}

// ── Typography & Headers Previews ───────────────────────────────────────────

@MultiBrightnessPreview(name: 'Section Header', previewGroup: 'Typography')
Widget previewSectionHeader() {
  return const Material(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: SectionHeaderWidget(label: 'Security Settings'),
    ),
  );
}

// ── Brand Previews ──────────────────────────────────────────────────────────

@Preview(name: 'App Icon', group: 'Brand', size: Size(120, 120))
Widget previewAppIcon() {
  return const Material(
    child: Center(
      child: AppIconWidget(height: 80, width: 80),
    ),
  );
}
