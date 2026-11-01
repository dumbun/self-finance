import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:signature/signature.dart';

class SignatureWidget extends StatefulWidget {
  const SignatureWidget({super.key, required this.controller});
  final SignatureController controller;

  @override
  SignatureWidgetState createState() => SignatureWidgetState();
}

class SignatureWidgetState extends State<SignatureWidget> {
  @override
  Widget build(BuildContext context) {
    final Color borderColor = AppColors.getLigthGreyColor.withValues(alpha: 0.3);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : 300;
        const double height = 220;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: BodyTwoDefaultText(
                    text: "Customer Signature (Required)",
                    bold: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: widget.controller.clear,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text("Clear"),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppColors.getErrorColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: Signature(
                controller: widget.controller,
                backgroundColor: Colors.white,
                width: width,
                height: height,
              ),
            ),
          ],
        );
      },
    );
  }
}
