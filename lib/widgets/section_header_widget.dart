import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

class SectionHeaderWidget extends StatelessWidget {
  const SectionHeaderWidget({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8, bottom: 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}

@Preview(name: 'Section Header', group: 'Headers')
Widget previewSectionHeader() {
  return const Material(
    child: SectionHeaderWidget(label: 'Security Settings'),
  );
}
