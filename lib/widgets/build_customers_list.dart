import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/contacts_model.dart';
import 'package:self_finance/providers/contacts_provider.dart';

class BuildCustomersListWidget extends ConsumerWidget {
  const BuildCustomersListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(contactsProvider)
        .when(
          data: (List<Contact> data) {
            return data.isNotEmpty
                ? ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (_, int index) {
                      final Contact curr = data[index];
                      return Dismissible(
                        key: ValueKey(curr.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: AppColors.contentColorBlue,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.phone_enabled_rounded),
                        ),
                        confirmDismiss: (_) async {
                          Utility.makeCall(phoneNumber: curr.number);
                          return false; // not actually dismissing
                        },
                        child: Card(
                          elevation: 0,
                          child: ListTile(
                            onTap: () => Routes.navigateToContactDetailsView(
                              context,
                              customerID: curr.id,
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: AppColors.getLigthGreyColor,
                            ),
                            title: BodyTwoDefaultText(
                              text: curr.name,
                              bold: true,
                            ),
                            subtitle: BodyTwoDefaultText(
                              text: curr.number,
                              color: AppColors.getLigthGreyColor,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: BodyOneDefaultText(
                      text: context.l10n.zeroContacts,
                      bold: true,
                    ),
                  );
          },
          error: (Object error, StackTrace stackTrace) {
            return Center(
              child: BodyOneDefaultText(
                text: context.l10n.errorFetchingContacts,
              ),
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
        );
  }
}
