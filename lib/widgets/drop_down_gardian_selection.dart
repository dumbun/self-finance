import 'dart:collection';

import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/constants/constants.dart';

typedef MenuEntry = DropdownMenuEntry<String>;

class DropDownGardianSelection extends StatefulWidget {
  const DropDownGardianSelection({
    super.key,
    required this.controller,
    this.width,
  });
  final TextEditingController controller;
  final double? width;

  @override
  State<DropDownGardianSelection> createState() =>
      _DropDownGardianSelectionState();
}

class _DropDownGardianSelectionState extends State<DropDownGardianSelection> {
  static final List<MenuEntry> menuEntries = UnmodifiableListView<MenuEntry>(
    Constant.guardianList.map<MenuEntry>(
      (String name) => MenuEntry(value: name, label: name),
    ),
  );
  String dropdownValue = Constant.guardianList.first;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double? effectiveWidth = widget.width ??
            (constraints.maxWidth.isFinite ? constraints.maxWidth : null);

        return DropdownMenu<String>(
          width: effectiveWidth,
          controller: widget.controller,
          initialSelection: Constant.guardianList.first,
          onSelected: (String? value) {
            // This is called when the user selects an item.
            setState(() {
              dropdownValue = value!;
            });
          },
          dropdownMenuEntries: menuEntries,
        );
      },
    );
  }
}
