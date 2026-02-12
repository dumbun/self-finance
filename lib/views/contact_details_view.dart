import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/customer_contacts_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/widgets/build_customer_details_widget.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/fab.dart';
import 'package:self_finance/widgets/slidable_widget.dart';

class ContactDetailsView extends ConsumerWidget {
  const ContactDetailsView({super.key, required this.customerID});
  final int customerID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void delateTheContact() async {
      await ref
          .read(asyncCustomersContactsProvider.notifier)
          .deleteCustomer(customerID: customerID);
      if (context.mounted) {
        Routes.navigateToDashboard(context: context);
      }
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
          bottom: TabBar(
            dividerColor: Colors.transparent,
            tabs: const [
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
                BuildCustomerDetailsWidget(customerID: customerID),
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
        return ref
            .watch(transactionsByCustomerIdProvider(customerID))
            .when(
              data: (List<Trx?> transactions) {
                if (transactions.isNotEmpty) {
                  return transactions.isNotEmpty
                      ? ListView.separated(
                          itemCount: transactions.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              SizedBox(height: 12.sp),
                          itemBuilder: (BuildContext context, int index) {
                            final Trx transaction = transactions[index]!;
                            return SlidableWidget(
                              transactionId: transaction.id!,
                              customerId: transaction.customerId,
                              child: Card(
                                child: GestureDetector(
                                  onTap: () =>
                                      Routes.navigateToTransactionDetailsView(
                                        transacrtionId: transaction.id!,
                                        customerId: customerID,
                                        context: context,
                                      ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.sp),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 24.sp,
                                          color:
                                              transaction.transacrtionType ==
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
                                            CurrencyWidget(
                                              amount: Utility.doubleFormate(
                                                transaction.amount,
                                              ),
                                            ),
                                            BodyOneDefaultText(
                                              text:
                                                  "${Constant.takenDateSmall}: ${transaction.transacrtionDate}",
                                            ),
                                            BodyOneDefaultText(
                                              text:
                                                  "${Constant.rateOfIntrest}: ${transaction.intrestRate}",
                                            ),
                                            BodyTwoDefaultText(
                                              text:
                                                  'ID:  ${transaction.id.toString()}',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
                } else {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      BodyTwoDefaultText(
                        bold: true,
                        textAlign: TextAlign.center,
                        text: Constant.noTransactionMessage,
                      ),
                      Icon(Icons.arrow_circle_down_rounded, size: 32),
                    ],
                  );
                }
              },
              error: (Object error, StackTrace stackTrace) => const Center(
                child: BodyOneDefaultText(
                  error: true,
                  text: Constant.errorFetchingTransactionMessage,
                ),
              ),
              loading: () =>
                  const Center(child: CircularProgressIndicator.adaptive()),
            );
      },
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
