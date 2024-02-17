import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/customer_contacts_provider.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/widgets/call_button_widget.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/title_widget.dart';

/// [updatedCustomerPhotoStringProvider] and [updatedCustomerProofStringProvider]
/// are the providers for the new updated images for the updating
/// this providers must update  the costomers old images as the primary values for the respected views before use
/// because of this providers have inital value has empty state

final updatedCustomerPhotoStringProvider = StateProvider<String>((ref) {
  return "";
});

final updatedCustomerProofStringProvider = StateProvider<String>((ref) {
  return "";
});

class ContactDetailsView extends ConsumerWidget {
  const ContactDetailsView({super.key, required this.customerID});
  final int customerID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void delateTheContact() {
      ref.read(asyncCustomersContactsProvider.notifier).deleteCustomer(customerID: customerID);
      Navigator.of(context).pop();
    }

    void navigateToEditingPage(Customer c) {
      Routes.navigateToContactEditingView(context: context, contact: c);
    }

    void preEditingSettings() async {
      final List<Customer> response = await BackEnd.fetchSingleContactDetails(id: customerID);
      ref.read(updatedCustomerPhotoStringProvider.notifier).state = response.first.photo;
      ref.read(updatedCustomerProofStringProvider.notifier).state = response.first.proof;
      navigateToEditingPage(response.first);
    }

    void popUpMenuSelected(String value) async {
      switch (value) {
        case '1':
          preEditingSettings();
          break;
        case '2':
          if (await AlertDilogs.alertDialogWithTwoAction(context, "Alert",
                  "By Pressing 'YES' you will remove all the details of this customer from your Date Base") ==
              1) {
            delateTheContact();
          }
          break;
        default:
          () {};
      }
    }

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          heroTag: Constant.saveButtonTag,
          enableFeedback: true,
          isExtended: true,
          tooltip: "Add new trancation to this customer",
          splashColor: AppColors.getPrimaryColor,
          backgroundColor: AppColors.getPrimaryColor,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            color: AppColors.getBackgroundColor,
          ),
          onPressed: () => Routes.navigateToAddNewTransactionToCustomerView(context: context, customerID: customerID),
        ),
        appBar: AppBar(
          forceMaterialTransparency: true,
          actions: [
            PopupMenuButton<String>(
              onSelected: (String value) => popUpMenuSelected(value),
              itemBuilder: (BuildContext context) => [
                _buildPopUpMenuItems(
                  value: '1',
                  icon: Icons.edit_rounded,
                  iconColor: AppColors.getPrimaryColor,
                  title: 'Edit',
                ),
                _buildPopUpMenuItems(
                  value: '2',
                  icon: Icons.delete_rounded,
                  iconColor: AppColors.getErrorColor,
                  title: "Delete",
                ),
              ],
            ),
          ],
          toolbarHeight: 32.sp,
          title: const BodyTwoDefaultText(text: "Contact Info", bold: true),
          bottom: const TabBar(
            dividerColor: Colors.transparent,
            tabs: [
              Tab(icon: Icon(Icons.person)),
              Tab(icon: Icon(Icons.history)),
            ],
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 16.sp),
            child: TabBarView(
              children: <Widget>[
                _buildCustomerDetails(),
                _buildTransactionsHistory(),
              ],
            ),
          ),
        ),
      ),
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
          ),
          SizedBox(width: 18.sp),
          BodyTwoDefaultText(text: title),
          SizedBox(width: 18.sp),
        ],
      ),
    );
  }

  Consumer _buildTransactionsHistory() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return ref.watch(asyncTransactionsProvider).when(
              data: (List<Trx> data) {
                final List<Trx> transactions = data.where((Trx element) => element.customerId == customerID).toList();
                return transactions.isNotEmpty
                    ? ListView.separated(
                        itemCount: transactions.length,
                        separatorBuilder: (BuildContext context, int index) => SizedBox(height: 12.sp),
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.sp),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.auto_stories, size: 24.sp),
                                  SizedBox(width: 18.sp),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      BodyOneDefaultText(
                                          text: "Taken Amount : ${Utility.doubleFormate(transactions[index].amount)}"),
                                      BodyOneDefaultText(text: "Taken Date : ${transactions[index].transacrtionDate}"),
                                      BodyOneDefaultText(text: "Rate of Intrest : ${transactions[index].intrestRate}"),
                                      BodyTwoDefaultText(text: transactions[index].transacrtionType),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: BodyOneDefaultText(
                          text: "No Transactions present. Add a transaction by pressing the + below ",
                        ),
                      );
              },
              error: (Object error, StackTrace stackTrace) => const Center(
                child: BodyOneDefaultText(text: "Error fetching the transactions please restart the application"),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            );
      },
    );
  }

  Consumer _buildCustomerDetails() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return ref.watch(asyncCustomersProvider).when(
              data: (List<Customer> data) {
                final Customer customer = data.where((Customer element) => element.id! == customerID).toList().first;
                return Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 20.sp),
                            _buildImage(customer.photo, customer.name),
                            SizedBox(height: 16.sp),
                            _buildCustomerName(customer.name),
                            SizedBox(height: 16.sp),
                            _buildNumberDetails(customer.number),
                            SizedBox(height: 12.sp),
                            _buildDetails(
                              const Icon(
                                Icons.location_on,
                                color: AppColors.getPrimaryColor,
                              ),
                              "Contact Address",
                              customer.address,
                            ),
                            SizedBox(height: 12.sp),
                            _buildDetails(
                              const Icon(
                                Icons.family_restroom,
                                color: AppColors.getPrimaryColor,
                              ),
                              "Gaurdian",
                              customer.guardianName,
                            ),
                            SizedBox(height: 12.sp),
                            if (customer.proof.isNotEmpty)
                              GestureDetector(
                                onTap: () => Routes.navigateToImageView(
                                  context: context,
                                  imageData: customer.proof,
                                  titile: "${customer.name} proof",
                                ),
                                child: Card(
                                  elevation: 0,
                                  child: Padding(
                                    padding: EdgeInsets.all(14.sp),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 12.sp),
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: AppColors.getPrimaryColor,
                                        ),
                                        SizedBox(width: 20.sp),
                                        const BodyOneDefaultText(
                                          text: "Show Customer proof",
                                          color: AppColors.getPrimaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: BodyTwoDefaultText(
                        text: "customer created on ${customer.createdDate}",
                        color: AppColors.getLigthGreyColor,
                      ),
                    )
                  ],
                );
              },
              error: (Object error, StackTrace stackTrace) => const Center(
                child: BodyOneDefaultText(text: "Error Fetching Customer contact details. Please restart the app"),
              ),
              loading: () => const Center(child: CircularProgressIndicator.adaptive()),
            );
      },
    );
  }

  Card _buildDetails(Widget icon, String title, String data) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(14.sp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 12.sp),
            icon,
            SizedBox(width: 20.sp),
            Column(
              mainAxisAlignment: title.isNotEmpty ? MainAxisAlignment.start : MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  BodyTwoDefaultText(
                    text: title,
                    color: AppColors.getLigthGreyColor,
                  ),
                SizedBox(height: 8.sp),
                SelectableText(
                  data,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18.sp,
                    fontFamily: "hell",
                    color: AppColors.getPrimaryColor,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildNumberDetails(String customerNumber) {
    return GestureDetector(
      onTap: () => Utility.makeCall(phoneNumber: customerNumber),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(14.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 12.sp),
              CallButtonWidget(phoneNumber: customerNumber),
              SizedBox(width: 20.sp),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BodyTwoDefaultText(
                    text: "Contact Number",
                    color: AppColors.getLigthGreyColor,
                  ),
                  SizedBox(height: 8.sp),
                  SelectableText(
                    customerNumber,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 18.sp,
                      fontFamily: "hell",
                      color: AppColors.getPrimaryColor,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Center _buildCustomerName(String customerName) {
    return Center(
      child: TitleWidget(
        text: customerName,
      ),
    );
  }

  /// [ _buildImage()] method to build the image of the customer
  Hero _buildImage(String imageData, String customerName) {
    return Hero(
      tag: Constant.customerImageTag,
      child: Center(
        child: CircularImageWidget(
          imageData: imageData,
          titile: "$customerName photo",
        ),
      ),
    );
  }
}
