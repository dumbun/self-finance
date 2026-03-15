import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:self_finance/core/theme/app_colors.dart' show AppColors;
import 'package:self_finance/widgets/snack_bar_widget.dart';

class ClipbordWidget extends StatefulWidget {
  const ClipbordWidget({super.key, required this.value});

  final String value;
  @override
  State<ClipbordWidget> createState() => _ClipbordWidgetState();
}

class _ClipbordWidgetState extends State<ClipbordWidget> {
  bool _isdone = false;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      key: ValueKey(widget.value),
      visible: _isdone,
      replacement: IconButton(
        onPressed: () async {
          setState(() => _isdone = true);
          try {
            await Clipboard.setData(ClipboardData(text: widget.value));
            if (!context.mounted) return;
            SnackBarWidget.snackBarWidget(
              context: context,
              message: "ID copied ✅",
            );
          } finally {
            if (mounted) setState(() => _isdone = false);
          }
        },
        icon: const Icon(
          Icons.copy_outlined,
          size: 18,
          color: AppColors.contentColorYellow,
        ),
      ),
      child: const CircularProgressIndicator.adaptive(),
    );
  }
}
