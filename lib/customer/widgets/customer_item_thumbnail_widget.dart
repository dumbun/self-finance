import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/theme/app_colors.dart';

class CustomerItemThumbnailWidget extends StatelessWidget {
  const CustomerItemThumbnailWidget({
    super.key,
    required this.imagePath,
    required this.title,
    this.width = 58,
    this.height = 58,
    this.borderRadius = 8,
  });

  final String imagePath;
  final String title;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final cleanPath = imagePath.trim();
    if (cleanPath.isEmpty) {
      return _buildPlaceholder();
    }

    Widget imageWidget;
    final isNetwork =
        cleanPath.startsWith('http://') || cleanPath.startsWith('https://');

    if (isNetwork) {
      imageWidget = Image.network(
        cleanPath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              ),
            ),
          );
        },
      );
    } else {
      final file = File(cleanPath);
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildPlaceholder(),
        );
      } else {
        return _buildPlaceholder();
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: GestureDetector(
        onTap: () {
          Routes.navigateToImageView(
            context: context,
            titile: title,
            imagePath: cleanPath,
          );
        },
        child: SizedBox(
          width: width,
          height: height,
          child: imageWidget,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.getPrimaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        color: AppColors.getPrimaryColor,
        size: width * 0.45,
      ),
    );
  }
}
