import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/providers/customer_contacts_provider.dart';
import 'package:self_finance/theme/colors.dart';

class AddTransactionToExistingContact extends ConsumerWidget {
  const AddTransactionToExistingContact({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController searchController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.getTransparentColor,
        title: const BodyOneDefaultText(text: "Please select the contact"),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.sp),
          child: RefreshIndicator.adaptive(
            onRefresh: () => ref.refresh(asyncCustomersContactsProvider.future),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CupertinoSearchTextField(
                  controller: searchController,
                  autocorrect: false,
                  enableIMEPersonalizedLearning: true,
                  style: const TextStyle(color: AppColors.getPrimaryColor, fontWeight: FontWeight.bold),
                  keyboardType: TextInputType.name,
                  placeholder: AutofillHints.name,
                  onChanged: (value) =>
                      ref.read(asyncCustomersContactsProvider.notifier).searchCustomer(givenInput: value),
                ),
                SizedBox(height: 16.sp),
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
                        child: ListView.separated(
                          itemCount: data.length,
                          separatorBuilder: (context, index) => SizedBox(height: 8.sp),
                          itemBuilder: (context, index) {
                            return Card(
                              child: GestureDetector(
                                onTap: () {
                                  //Todo using [id] and [name] and [mobile number] fetch the customer total details and show it on the next view
                                  print(data[index]["Customer_ID"]);
                                  print(data[index]["Customer_Name"]);
                                  print(data[index]["Contact_Number"]);
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(16.sp),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      BodyTwoDefaultText(
                                        text: data[index]["Customer_Name"] as String,
                                        bold: true,
                                      ),
                                      BodyTwoDefaultText(
                                        text: data[index]["Contact_Number"] as String,
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
}
