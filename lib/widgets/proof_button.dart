import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

class ProofButton extends ConsumerWidget {
  const ProofButton({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return GestureDetector(
      onTap: () {
        final String? proofFullPath = ref.read(
          customerProofPathProvider(customerId),
        );
        if (proofFullPath != null && context.mounted) {
          Routes.navigateToImageView(
            context: context,
            imagePath: proofFullPath,
            titile: l10n.customerProof,
          );
        } else if (context.mounted) {
          SnackBarWidget.snackBarWidget(
            context: context,
            message: l10n.error,
          );
        }
      },
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.getPrimaryColor,
              ),
              const SizedBox(width: 20),
              BodyOneDefaultText(
                text: l10n.showCustomerProof,
                color: AppColors.getPrimaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
