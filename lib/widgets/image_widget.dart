import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:self_finance/core/constants/routes.dart';
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
    if (imagePath.isEmpty) {
      return SizedBox(height: height, width: width, child: errorBuilder);
    }

    final String appDirPath = ref.watch(appDirProvider);
    final String fullPath =
        p.isAbsolute(imagePath) ? imagePath : p.join(appDirPath, imagePath);

    final double devicePixelRatio =
        MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
    final int? cacheDimension = (width > 0 && width.isFinite)
        ? (width * devicePixelRatio).round()
        : null;


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
        cacheWidth: cacheDimension,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) =>
            SizedBox(height: height, width: width, child: errorBuilder),
      ),
    );
  }
}
