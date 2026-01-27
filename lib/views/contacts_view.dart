import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/providers/customer_contacts_provider.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/widgets/build_customers_list.dart';
import 'package:self_finance/widgets/refresh_widget.dart';

class ContactsView extends ConsumerWidget {
  const ContactsView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const BodyTwoDefaultText(text: Constant.contact, bold: true),
      ),
      body: RefreshWidget(
        onRefresh: () => ref.refresh(asyncCustomersContactsProvider.future),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.sp, horizontal: 16.sp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CupertinoSearchTextField(
                  autocorrect: false,
                  enableIMEPersonalizedLearning: true,
                  style: const TextStyle(
                    color: AppColors.getPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  keyboardType: TextInputType.name,
                  onChanged: (String value) => ref
                      .read(asyncCustomersContactsProvider.notifier)
                      .searchCustomer(givenInput: value),
                ),
                SizedBox(height: 12.sp),
                const Expanded(child: BuildCustomersListWidget()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
