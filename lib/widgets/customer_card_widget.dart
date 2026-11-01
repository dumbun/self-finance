import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';

class CustomerCardWidget extends ConsumerWidget {
  const CustomerCardWidget({super.key, required this.customerId});
  final String customerId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return GestureDetector(
      onTap: () =>
          Routes.navigateToContactDetailsView(context, customerID: customerId),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ref
              .watch(customerProvider(customerId))
              .when(
                data: (Customer? data) {
                  if (data == null) {
                    return BodyTwoDefaultText(
                      text: l10n.errorFetchingContacts,
                    );
                  }
                  return Row(
                    children: [
                      CircularImageWidget(
                        customeSize: 46,
                        imageData: data.photo,
                        titile: data.name,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BodyTwoDefaultText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              text: "Name: ${data.name}",
                              bold: true,
                            ),
                            BodyTwoDefaultText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              text: data.guardianName,
                              bold: true,
                            ),
                            BodyTwoDefaultText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              text: "From: ${data.address}",
                              bold: true,
                            ),
                            BodyTwoDefaultText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              text: "Phone: ${data.number}",
                              bold: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                error: (error, stackTrace) => BodyTwoDefaultText(
                  text: l10n.errorFetchingContacts,
                ),
                loading: () => BodyTwoDefaultText(text: l10n.loading),
              ),
        ),
      ),
    );
  }
}
