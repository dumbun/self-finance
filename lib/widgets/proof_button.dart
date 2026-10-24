import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

class ProofButton extends ConsumerWidget {
  const ProofButton({super.key, required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        final String? proofFullPath =
            ref.read(customerProofPathProvider(customerId));
        if (proofFullPath != null && context.mounted) {
          Routes.navigateToImageView(
            context: context,
            imagePath: proofFullPath,
            titile: "proof",
          );
        } else if (context.mounted) {
          SnackBarWidget.snackBarWidget(
            context: context,
            message: Constant.error,
          );
        }
      },
      child: const Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Row(
            children: [
              SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.getPrimaryColor,
              ),
              SizedBox(width: 20),
              BodyOneDefaultText(
                text: "Show Customer proof",
                color: AppColors.getPrimaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
