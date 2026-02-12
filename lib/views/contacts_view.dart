import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/providers/customer_contacts_provider.dart';
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
                SearchBar(
                  onChanged: (String value) => ref
                      .read(asyncCustomersContactsProvider.notifier)
                      .searchCustomer(givenInput: value),
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 12.sp),
                  ),
                  hintStyle: WidgetStatePropertyAll(
                    TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(20.sp),
                    ),
                  ),
                  leading: const Icon(Icons.search),
                  elevation: WidgetStatePropertyAll(0),
                  hintText: "phone no. or name",
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
