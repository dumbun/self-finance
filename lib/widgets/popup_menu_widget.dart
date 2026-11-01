import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/loading_popup_widget.dart';

class PopupMenuWidget extends ConsumerWidget {
  const PopupMenuWidget({super.key, required this.customerId});
  final String customerId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    Future<void> delateTheContact() async {
      await runWithLoading(
        context,
        () => ref
            .read<CustomerNotifier>(customerProvider(customerId).notifier)
            .deleteCustomer(customerId),
      );

      if (context.mounted) {
        Routes.navigateToDashboard(context: context);
      }
    }

    void popUpMenuSelected(String value, Customer customer) async {
      switch (value) {
        case '1':
          Routes.navigateToContactEditingView(
            context: context,
            customer: customer,
          );
          break;
        case '2':
          if (await AlertDilogs.alertDialogWithTwoAction(
                context,
                l10n.alert,
                l10n.contactDeleteMessage,
              ) ==
              1) {
            await delateTheContact();
          }
          break;
        default:
          () {};
      }
    }

    return ref
        .watch(customerProvider(customerId))
        .when(
          data: (Customer? customer) {
            if (customer == null) {
              return BodyTwoDefaultText(
                text: l10n.errorFetchingContacts,
              );
            }

            return PopupMenuButton<String>(
              onSelected: (String value) => popUpMenuSelected(value, customer),
              itemBuilder: (BuildContext context) => [
                _buildPopUpMenuItems(
                  value: '1',
                  icon: Icons.edit_rounded,
                  iconColor: AppColors.getPrimaryColor,
                  title: l10n.edit,
                ),
                _buildPopUpMenuItems(
                  value: '2',
                  icon: Icons.delete_rounded,
                  iconColor: AppColors.getErrorColor,
                  title: l10n.delete,
                ),
              ],
            );
          },
          error: (Object error, stackTrace) =>
              BodySmallText(text: error.toString()),
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
        );
  }

  PopupMenuItem<String> _buildPopUpMenuItems({
    required String value,
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 18),
          BodyTwoDefaultText(text: title),
          const SizedBox(width: 18),
        ],
      ),
    );
  }
}
