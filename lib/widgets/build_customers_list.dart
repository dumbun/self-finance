import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/models/contacts_model.dart';
import 'package:self_finance/providers/customer_contacts_provider.dart';

class BuildCustomersListWidget extends ConsumerWidget {
  const BuildCustomersListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(asyncCustomersContactsProvider)
        .when(
          data: (List<Contact> data) {
            return data.isNotEmpty
                ? ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Contact curr = data[index];
                      return GestureDetector(
                        onTap: () => Routes.navigateToContactDetailsView(
                          context,
                          customerID: curr.id,
                        ),
                        child: Card(
                          margin: EdgeInsets.only(top: 16.sp),
                          elevation: 0,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.sp,
                              vertical: 12.sp,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    BodyTwoDefaultText(
                                      text: curr.name,
                                      bold: true,
                                    ),
                                    BodyTwoDefaultText(
                                      text: curr.number,
                                      color: AppColors.getLigthGreyColor,
                                    ),
                                  ],
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: AppColors.getLigthGreyColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: BodyOneDefaultText(
                      text: Constant.zeroContacts,
                      bold: true,
                    ),
                  );
          },
          error: (Object error, StackTrace stackTrace) {
            return const Center(
              child: BodyOneDefaultText(
                text: Constant.errorFetchingContactMessage,
              ),
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
        );
  }
}
