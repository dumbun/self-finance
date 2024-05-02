import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/theme/app_colors.dart';

class ExpandableFab extends StatelessWidget {
  const ExpandableFab({super.key});

  Card _buildFlotingActionButtons(
    void Function()? onTap,
    IconData? icon,
    String title,
  ) {
    return Card(
      elevation: 0,
      color: AppColors.getPrimaryColor,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: AppColors.getPrimaryTextColor,
        ),
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

  @override
  Widget build(BuildContext context) {
    void navigateToContactsView() {
      Navigator.of(context).pop(context);
      Routes.navigateToContactsView(context);
    }

    void navigateToAddNewEntry() {
      Navigator.of(context).pop(context);
      Routes.navigateToAddNewEntry(context: context);
    }

    return FloatingActionButton(
      shape: const CircleBorder(),
      tooltip: Constant.addNewTransactionToolTip,
      elevation: 10.sp,
      backgroundColor: AppColors.getPrimaryColor,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      highlightElevation: 20.sp,
      hoverElevation: 20.sp,
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 56.sp,
              padding: EdgeInsets.all(20.sp),
              margin: EdgeInsets.symmetric(vertical: 20.sp),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFlotingActionButtons(
                    navigateToAddNewEntry,
                    Icons.add,
                    "Create new Contact",
                  ),
                  SizedBox(
                    height: 12.sp,
                  ),
                  _buildFlotingActionButtons(
                    navigateToContactsView,
                    Icons.contact_page_rounded,
                    "Show Contacts",
                  ),
                ],
              ),
            );
          },
        );
      },
      child: const Icon(Icons.edit),
    );
  }
}
