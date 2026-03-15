import 'package:flutter/material.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';

class ExpandableFab extends StatelessWidget {
  const ExpandableFab({super.key});

  Card _buildFlotingActionButtons(
    void Function()? onTap,
    Icon icon,
    String title,
  ) {
    return Card(
      color: AppColors.getPrimaryColor,
      child: ListTile(
        onTap: onTap,
        leading: icon,
        title: BodyTwoDefaultText(
          text: title,
          color: AppColors.getPrimaryTextColor,
          bold: true,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppColors.getPrimaryTextColor,
        ),
      ),
    );
  }

  void _navigateToContactsView(BuildContext context) {
    Navigator.of(context).pop();
    Routes.navigateToContactsView(context);
  }

  void _navigateToAddNewEntry(BuildContext context) {
    Navigator.of(context).pop();
    Routes.navigateToAddNewEntry(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      splashColor: AppColors.getPrimaryColor,
      backgroundColor: AppColors.getPrimaryColor,
      tooltip: Constant.addNewTransactionToolTip,
      onPressed: () async {
        await showModalBottomSheet(
          enableDrag: true,
          showDragHandle: true,
          useSafeArea: true,
          context: context,
          builder: (BuildContext context) {
            return SingleChildScrollView(
              child: Container(
                height: 200,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(vertical: 20),
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFlotingActionButtons(
                      () => _navigateToAddNewEntry(context),
                      const Icon(Icons.add, color: AppColors.contentColorBlack),
                      "Create new Contact",
                    ),
                    const SizedBox(height: 12),
                    _buildFlotingActionButtons(
                      () => _navigateToContactsView(context),
                      const Icon(
                        Icons.contact_page_rounded,
                        color: AppColors.contentColorBlack,
                      ),
                      "Show Contacts",
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: const Icon(Icons.edit, color: AppColors.getBackgroundColor),
    );
  }
}
