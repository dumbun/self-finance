import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/providers/settings_provider.dart';

class BiometricButtonWidget extends ConsumerWidget {
  const BiometricButtonWidget({super.key, this.onPressed});
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(biometricsProvider)
        .when(
          data: (bool data) => data
              ? IconButton(
                  onPressed: onPressed,
                  icon: const Icon(
                    Icons.fingerprint,
                    color: AppColors.getPrimaryColor,
                    size: 42,
                  ),
                )
              : const SizedBox.shrink(),
          error: (error, stackTrace) =>
              const BodyTwoDefaultText(text: Constant.errorUserFetch),
          loading: () => const CircularProgressIndicator.adaptive(),
        );
  }
}
