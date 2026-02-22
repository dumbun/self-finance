import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart' show DeviceExt;
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
          setState(() {
            _isdone = !_isdone;
          });
          await Clipboard.setData(ClipboardData(text: widget.value)).then((
            value,
          ) {
            setState(() {
              _isdone = !_isdone;
            });
          });
          if (context.mounted) {
            SnackBarWidget.snackBarWidget(
              context: context,
              message: "ID copied ✅",
            );
          }
        },
        icon: Icon(
          Icons.copy_outlined,
          size: 18.sp,
          color: AppColors.contentColorYellow,
        ),
      ),
      child: const CircularProgressIndicator.adaptive(),
    );
  }
}
