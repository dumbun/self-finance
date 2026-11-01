import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/providers/item_provider.dart';
import 'package:self_finance/widgets/image_widget.dart';

class ItemImageWidget extends ConsumerWidget {
  const ItemImageWidget({super.key, required this.itemId});
  final String itemId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return ref
        .watch(itemByIdProvider(itemId))
        .when(
          data: (Items? item) {
            if (item == null) {
              return BodyTwoDefaultText(text: l10n.errorFetchingItem);
            }
            if (item.photo.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyTwoDefaultText(
                    bold: true,
                    text: l10n.itemDescription,
                  ),
                  Card(
                    elevation: 2,
                    child: ListTile(
                      title: BodyTwoDefaultText(
                        bold: true,
                        text: item.description,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyTwoDefaultText(
                    bold: true,
                    text: l10n.customerItem,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsetsGeometry.all(12),
                        child: Column(
                          children: [
                            ImageWidget(
                              title: item.description,
                              height: 72,
                              width: 72,
                              imagePath: item.photo,
                              fit: BoxFit.scaleDown,
                            ),
                            BodyTwoDefaultText(
                              bold: true,
                              text: item.description,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
          error: (error, stackTrace) =>
              BodyTwoDefaultText(text: error.toString()),
          loading: () => const CircularProgressIndicator.adaptive(),
        );
  }
}
