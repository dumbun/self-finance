import 'package:flutter/material.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/utility/image_catch_manager.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

class PawnedItemImageWidget extends StatelessWidget {
  const PawnedItemImageWidget({super.key, required this.itemID});
  final int itemID;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: BackEnd.fetchRequriedItem(itemId: itemID),
      builder: (BuildContext context, AsyncSnapshot<List<Items>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator.adaptive();
        } else if (snapshot.hasData) {
          final List<Items> data = snapshot.requireData;
          return Card(
            child: ListTile(
              onTap: () {
                if (data.first.photo.isNotEmpty) {
                  Routes.navigateToImageView(
                    context: context,
                    imageWidget: ImageCacheManager.getCachedImage(
                      data.first.photo,
                      44,
                      44,
                    ),
                    titile: data.first.description,
                  );
                } else {
                  SnackBarWidget.snackBarWidget(
                    context: context,
                    message: "No Image Found 😔",
                  );
                }
              },
              leading: const Icon(Icons.topic_outlined),
              title: const BodyTwoDefaultText(text: 'Show Item', bold: true),
              subtitle: BodyTwoDefaultText(text: data.first.description),
              trailing: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.getPrimaryColor,
              ),
            ),
          );
        } else {
          return BodyTwoDefaultText(text: snapshot.error.toString());
        }
      },
    );
  }
}
