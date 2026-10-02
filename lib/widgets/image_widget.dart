import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/providers/app_dir_provider.dart';

class ImageWidget extends ConsumerWidget {
  const ImageWidget({
    super.key,
    required this.imagePath,
    required this.height,
    required this.width,
    required this.title,
    this.fit = BoxFit.cover,
    this.showImage = true,
    this.errorBuilder = const SizedBox.shrink(),
  });

  final String title;
  final String imagePath;
  final double height;
  final double width;
  final BoxFit fit;
  final bool showImage;
  final Widget errorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<String> appDir = ref.read(appDirProvider);

    return appDir.when(
      data: (String appDirPath) {
        final String fullPath = p.join(appDirPath, imagePath);

        return GestureDetector(
          onTap: showImage
              ? () {
                  Routes.navigateToImageView(
                    context: context,
                    titile: title,
                    imagePath: fullPath,
                  );
                }
              : null,
          child: Image.file(
            File(fullPath),
            height: height,
            width: width,
            fit: fit,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) =>
                SizedBox(height: height, width: width, child: errorBuilder),
          ),
        );
      },
      loading: () => SizedBox(
        height: height,
        width: width,
        child: const Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (Object error, StackTrace stackTrace) => SizedBox(
        height: height,
        width: width,
        child: Center(child: BodyOneDefaultText(text: error.toString())),
      ),
    );
  }
}
