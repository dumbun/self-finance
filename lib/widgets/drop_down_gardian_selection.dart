import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:self_finance/core/constants/constants.dart';

typedef MenuEntry = DropdownMenuEntry<String>;

class DropDownGardianSelection extends StatefulWidget {
  const DropDownGardianSelection({super.key, required this.controller});
  final TextEditingController controller;
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
    return DropdownMenu<String>(
      key: UniqueKey(),
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
  }
}
