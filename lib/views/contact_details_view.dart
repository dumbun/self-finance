import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/fonts/selectable_text.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/app_currency_provider.dart';
import 'package:self_finance/providers/customer_contacts_provider.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/widgets/call_button_widget.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/fab.dart';
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
      ref
          .read(asyncCustomersContactsProvider.notifier)
          .deleteCustomer(customerID: customerID);
      Navigator.of(context).pop();
    }

    void editSelected() async {
      Routes.navigateToContactEditingView(
        ref: ref,
        context: context,
        customerID: customerID,
      );
    }

    void popUpMenuSelected(String value) async {
      switch (value) {
        case '1':
          editSelected();
          break;
        case '2':
          if (await AlertDilogs.alertDialogWithTwoAction(
                context,
                "Alert",
                Constant.contactDeleteMessage,
              ) ==
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
        floatingActionButton: Fab(
          icon: Icons.add,
          heroTag: Constant.saveButtonTag,
          onPressed: () => Routes.navigateToAddNewTransactionToCustomerView(
            context: context,
            customerID: customerID,
          ),
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

  Consumer _buildTransactionsHistory() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final String currencyType = ref.watch(currencyProvider);
        return ref
            .watch(asyncTransactionsProvider)
            .when(
              data: (List<Trx> data) {
                final List<Trx> transactions = data
                    .where((Trx element) => element.customerId == customerID)
                    .toList();
                return transactions.isNotEmpty
                    ? ListView.separated(
                        itemCount: transactions.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            SizedBox(height: 12.sp),
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () =>
                                Routes.navigateToTransactionDetailsView(
                                  transacrtion: transactions[index],
                                  context: context,
                                ),
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(16.sp),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 24.sp,
                                      color:
                                          transactions[index]
                                                  .transacrtionType ==
                                              Constant.active
                                          ? AppColors.getGreenColor
                                          : AppColors.getErrorColor,
                                    ),
                                    SizedBox(width: 18.sp),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        BodyOneDefaultText(
                                          text:
                                              "${Constant.takenAmount}: ${Utility.doubleFormate(transactions[index].amount)} $currencyType",
                                        ),
                                        BodyOneDefaultText(
                                          text:
                                              "${Constant.takenDateSmall}: ${transactions[index].transacrtionDate}",
                                        ),
                                        BodyOneDefaultText(
                                          text:
                                              "${Constant.rateOfIntrest}: ${transactions[index].intrestRate}",
                                        ),
                                        BodyTwoDefaultText(
                                          text: transactions[index]
                                              .transacrtionType,
                                        ),
                                      ],
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
                          text: Constant.noTransactionMessage,
                        ),
                      );
              },
              error: (Object error, StackTrace stackTrace) => const Center(
                child: BodyOneDefaultText(
                  text: Constant.errorFetchingTransactionMessage,
                ),
              ),
              loading: () =>
                  const Center(child: CircularProgressIndicator.adaptive()),
            );
      },
    );
  }

  Consumer _buildCustomerDetails() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return ref
            .watch(asyncCustomersProvider)
            .when(
              data: (List<Customer> data) {
                final Customer customer = data
                    .where((Customer element) => element.id! == customerID)
                    .toList()
                    .first;
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

                            // Customer Name
                            Padding(
                              padding: EdgeInsets.only(
                                left: 20.sp,
                                right: 20.sp,
                              ),
                              child: Center(
                                child: TitleWidget(
                                  textAlign: TextAlign.center,
                                  text: customer.name,
                                ),
                              ),
                            ),
                            SizedBox(height: 16.sp),

                            _buildNumberDetails(customer.number),
                            SizedBox(height: 12.sp),
                            _buildDetails(
                              const Icon(
                                Icons.location_on,
                                color: AppColors.getPrimaryColor,
                              ),
                              Constant.customerAddress,
                              customer.address,
                            ),
                            SizedBox(height: 12.sp),
                            _buildDetails(
                              const Icon(
                                Icons.family_restroom,
                                color: AppColors.getPrimaryColor,
                              ),
                              Constant.guardianName,
                              customer.guardianName,
                            ),
                            SizedBox(height: 12.sp),
                            if (customer.proof.isNotEmpty)
                              GestureDetector(
                                onTap: () => Routes.navigateToImageView(
                                  context: context,
                                  imageWidget: Image.file(File(customer.proof)),
                                  titile: "${customer.name} proof",
                                ),
                                child: Card(
                                  elevation: 0,
                                  child: Padding(
                                    padding: EdgeInsets.all(14.sp),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                        text: "customer created on ${(customer.createdDate)}",
                        color: AppColors.getLigthGreyColor,
                      ),
                    ),
                  ],
                );
              },
              error: (Object error, StackTrace stackTrace) => const Center(
                child: BodyOneDefaultText(
                  text: Constant.errorFetchingContactMessage,
                ),
              ),
              loading: () =>
                  const Center(child: CircularProgressIndicator.adaptive()),
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
              mainAxisAlignment: title.isNotEmpty
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  BodyTwoDefaultText(
                    text: title,
                    color: AppColors.getLigthGreyColor,
                  ),
                SizedBox(height: 8.sp),
                SelectableTextWidget(data: data),
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
                  SelectableTextWidget(data: customerNumber),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// [ _buildImage()] method to build the image of the customer
  Center _buildImage(String imageData, String customerName) {
    return Center(
      child: CircularImageWidget(
        imageData: imageData,
        titile: "$customerName photo",
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
          Icon(icon, color: iconColor),
          SizedBox(width: 18.sp),
          BodyTwoDefaultText(text: title),
          SizedBox(width: 18.sp),
        ],
      ),
    );
  }
}
