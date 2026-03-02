import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/providers/app_dir_provider.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

class ProofButton extends ConsumerWidget {
  const ProofButton({super.key, required this.proofImagePath});

  final String proofImagePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(appDirProvider)
        .when(
          data: (String appDir) => GestureDetector(
            onTap: () {
              final String b = p.join(appDir, proofImagePath);
              if (context.mounted && File(b).existsSync()) {
                Routes.navigateToImageView(
                  context: context,
                  imagePath: b,
                  titile: "proof",
                );
              } else if (context.mounted) {
                SnackBarWidget.snackBarWidget(
                  context: context,
                  message: Constant.error,
                );
              }
            },
            child: Card(
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.all(14.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 12.sp),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.getPrimaryColor,
                    ),
                    SizedBox(width: 20.sp),
                    const BodyOneDefaultText(
                      text: "Show Customer proof",
                      color: AppColors.getPrimaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
          error: (_, _) => const BodyTwoDefaultText(text: Constant.error),
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
        );
  }
}
