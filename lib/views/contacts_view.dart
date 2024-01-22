import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/customer_contacts_provider.dart';
import 'package:self_finance/theme/colors.dart';

class ContactsView extends ConsumerWidget {
  const ContactsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController searchController = TextEditingController();

    void navigateToDetailsView(
      List<Customer> customer,
      List<Items> customerItems,
      List<Trx> customerTransactions,
    ) {
      Routes.navigateToContactDetailsView(
        context,
        customer: customer.first,
        items: customerItems,
        transacrtions: customerTransactions,
      );
    }

    Consumer buildCustomerList() {
      return Consumer(
        builder: (context, ref, child) {
          return ref.watch(asyncCustomersContactsProvider).when(
                data: (data) {
                  return data.isNotEmpty
                      ? Expanded(
                          child: ListView.separated(
                            itemCount: data.length,
                            separatorBuilder: (BuildContext context, int index) => SizedBox(height: 8.sp),
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () async {
                                  final List<Customer> customer =
                                      await BackEnd.fetchSingleContactDetails(id: data[index].id);
                                  final List<Items> customerItems =
                                      await BackEnd.fetchitemOfRequriedCustomer(customerID: data[index].id);
                                  final List<Trx> customerTransactions =
                                      await BackEnd.fetchRequriedCustomerTransactions(customerId: data[index].id);
                                  navigateToDetailsView(customer, customerItems, customerTransactions);
                                },
                                child: Card(
                                  elevation: 0,
                                  child: Padding(
                                    padding: EdgeInsets.all(16.sp),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
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

    return Scaffold(
      appBar: AppBar(
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
                  onChanged: (value) =>
                      ref.read(asyncCustomersContactsProvider.notifier).searchCustomer(givenInput: value),
                ),
                SizedBox(height: 16.sp),
                buildCustomerList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
