import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/customer_contacts_provider.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/widgets/call_button_widget.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/title_widget.dart';

final updatedCustomerPhotoStringProvider = StateProvider<String>((ref) {
  return "";
});

final updatedCustomerProofStringProvider = StateProvider<String>((ref) {
  return "";
});

class ContactDetailsView extends ConsumerWidget {
  const ContactDetailsView({
    super.key,
    required this.customer,
    required this.transacrtions,
    required this.items,
  });
  final Customer customer;
  final List<Trx> transacrtions;
  final List<Items> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void delateTheContact() {
      ref.read(asyncCustomersContactsProvider.notifier).deleteCustomer(customerID: customer.id!);
      Navigator.pop(context);
    }

    void preEditingSettings() {
      ref.read(updatedCustomerPhotoStringProvider.notifier).state = customer.photo;
      ref.read(updatedCustomerProofStringProvider.notifier).state = customer.proof;
      Routes.navigateToContactEditingView(context: context, contact: customer);
    }

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          enableFeedback: true,
          isExtended: true,
          tooltip: "Add new trancation to this customer",
          splashColor: AppColors.getPrimaryColor,
          backgroundColor: AppColors.getPrimaryColor,
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
          onPressed: () {},
        ),
        appBar: AppBar(
          actions: [
            PopupMenuButton<String>(
              onSelected: (String value) async {
                switch (value) {
                  case '1':
                    preEditingSettings();
                    break;
                  case '2':
                    if (await AlertDilogs.alertDialogWithTwoAction(
                          context,
                          "Alert",
                          "By Pressing 'YES' you will remove all the details of this customer from your Date Base",
                        ) ==
                        1) {
                      delateTheContact();
                    }
                    break;
                  default:
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: '1',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.edit,
                        color: AppColors.getPrimaryColor,
                      ),
                      SizedBox(width: 10.sp),
                      const BodyTwoDefaultText(text: "Edit")
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: '2',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.delete,
                        color: AppColors.getErrorColor,
                      ),
                      SizedBox(width: 10.sp),
                      const BodyTwoDefaultText(text: "Delete")
                    ],
                  ),
                ),
              ],
            ),
          ],
          toolbarHeight: 32.sp,
          title: BodyTwoDefaultText(text: customer.name),
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
            padding: EdgeInsets.all(16.sp),
            child: TabBarView(
              children: <Widget>[
                _details(context),
                _history(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _history() {
    return ListView.separated(
      itemCount: transacrtions.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.sp),
      itemBuilder: (context, index) {
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
                    BodyOneDefaultText(text: "Taken Amount : ${Utility.doubleFormate(transacrtions[index].amount)}"),
                    BodyOneDefaultText(text: "Taken Date : ${transacrtions[index].transacrtionDate}"),
                    BodyOneDefaultText(text: "Rate of Intrest : ${transacrtions[index].intrestRate}"),
                    BodyTwoDefaultText(text: transacrtions[index].transacrtionType),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Stack _details(BuildContext context) {
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
                _buildImage(),
                SizedBox(height: 16.sp),
                _buildCustomerName(),
                SizedBox(height: 16.sp),
                _buildNumberDetails(),
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
                    customer.guardianName),
                SizedBox(height: 12.sp),
                if (customer.proof.isNotEmpty)
                  GestureDetector(
                    onTap: () => Routes.navigateToImageView(
                      context: context,
                      imageData: customer.proof,
                      titile: "${customer.name} proof",
                    ),
                    child: Card(
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
                            )
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

  GestureDetector _buildNumberDetails() {
    return GestureDetector(
      onTap: () => Utility.makeCall(phoneNumber: customer.number),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(14.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 12.sp),
              CallButtonWidget(phoneNumber: customer.number),
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
                    customer.number,
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

  Center _buildCustomerName() {
    return Center(
      child: TitleWidget(
        text: customer.name,
      ),
    );
  }

  /// [ _buildImage()] method to build the image of the customer
  Center _buildImage() {
    return Center(child: CircularImageWidget(imageData: customer.photo, titile: "customer photo"));
  }
}
