import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/contacts_model.dart';
import 'package:self_finance/providers/customer_contacts_provider.dart';
import 'package:self_finance/theme/colors.dart';

class ContactsView extends ConsumerWidget {
  const ContactsView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const BodyTwoDefaultText(
          text: "Contacts",
          bold: true,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.sp, horizontal: 16.sp),
          child: RefreshIndicator.adaptive(
            onRefresh: () => ref.refresh(asyncCustomersContactsProvider.future),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CupertinoSearchTextField(
                  autocorrect: false,
                  enableIMEPersonalizedLearning: true,
                  style: const TextStyle(color: AppColors.getPrimaryColor, fontWeight: FontWeight.bold),
                  keyboardType: TextInputType.name,
                  onChanged: (value) =>
                      ref.read(asyncCustomersContactsProvider.notifier).searchCustomer(givenInput: value),
                ),
                SizedBox(height: 8.sp),
                _buildCustomerList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Consumer _buildCustomerList() {
    return Consumer(
      builder: (context, ref, child) {
        return ref.watch(asyncCustomersContactsProvider).when(
              data: (data) {
                return data.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () => contactSelected(data, index, context),
                              child: Card(
                                margin: EdgeInsets.only(top: 16.sp),
                                elevation: 0,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          BodyTwoDefaultText(
                                            text: data[index].name,
                                            bold: true,
                                          ),
                                          BodyTwoDefaultText(
                                            text: data[index].number,
                                            color: AppColors.getLigthGreyColor,
                                          )
                                        ],
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppColors.getLigthGreyColor,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: BodyOneDefaultText(
                          text: "0 Contacts Found 🫠",
                          bold: true,
                        ),
                      );
              },
              error: (error, stackTrace) {
                return const Center(
                  child: BodyOneDefaultText(text: "Error fetching customers contacts please try again 😶‍🌫️"),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            );
      },
    );
  }

  void contactSelected(List<Contact> data, int index, BuildContext context) {
    Routes.navigateToContactDetailsView(context, customerID: data[index].id);
  }
}
