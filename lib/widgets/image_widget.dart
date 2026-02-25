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
    this.cache,
    this.fit = BoxFit.fill,
    required this.title,
    this.showImage = true,
    this.errorBuilder = const SizedBox.shrink(),
  });

  final String title;
  final String imagePath;
  final double height;
  final double width;
  final int? cache;
  final BoxFit? fit;
  final bool showImage;
  final Widget errorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(appDirProvider)
        .when(
          data: (String data) {
            final String imageWithAppDir = p.join(data, imagePath);
            return GestureDetector(
              onTap: () => showImage
                  ? Routes.navigateToImageView(
                      context: context,
                      titile: title,
                      imagePath: imageWithAppDir,
                    )
                  : null,
              child: Image.file(
                File(imageWithAppDir),
                errorBuilder: (_, _, _) => errorBuilder,
                height: height,
                width: width,
                fit: fit,
                cacheHeight: cache,
                cacheWidth: cache,
              ),
            );
          },
          error: (error, stackTrace) => const BodyOneDefaultText(text: "text"),
          loading: () => const CircularProgressIndicator.adaptive(),
        );
  }
}
